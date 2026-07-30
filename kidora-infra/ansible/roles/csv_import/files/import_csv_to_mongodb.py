#!/usr/bin/env python3
"""
Import CSV files into MongoDB.
Reads all kidora_test.*.csv files from the data_automation directory,
extracts the collection name from the filename, and imports data into MongoDB.

Usage:
    python3 import_csv_to_mongodb.py [--dry-run] [--csv-dir /path/to/csv]

Environment variables:
    MONGO_HOST      - MongoDB host (default: localhost)
    MONGO_PORT      - MongoDB port (default: 27017)
    MONGO_USER      - MongoDB username
    MONGO_PASSWORD  - MongoDB password
    MONGO_DB        - MongoDB database name (default: kidora)
    MONGO_AUTH_DB   - MongoDB authentication database (default: admin)
"""

import os
import sys
import csv
import glob
import argparse
from datetime import datetime
from urllib.parse import quote_plus
from bson import ObjectId
from pymongo import MongoClient, errors


def parse_value(value):
    """Parse a CSV string value into an appropriate Python type."""
    if value is None or value.strip() == '':
        return None
    
    stripped = value.strip()
    
    # Try boolean
    if stripped.lower() == 'true':
        return True
    if stripped.lower() == 'false':
        return False
    
    # Try integer
    try:
        if stripped.isdigit() or (stripped.startswith('-') and stripped[1:].isdigit()):
            return int(stripped)
    except (ValueError, OverflowError):
        pass
    
    # Try float
    try:
        float_val = float(stripped)
        if '.' in stripped or 'e' in stripped.lower():
            return float_val
    except (ValueError, OverflowError):
        pass
    
    # Try ObjectId (24 hex characters)
    if len(stripped) == 24 and all(c in '0123456789abcdefABCDEF' for c in stripped):
        try:
            return ObjectId(stripped)
        except:
            pass
    
    # Try datetime (ISO format)
    try:
        return datetime.fromisoformat(stripped.replace('Z', '+00:00'))
    except (ValueError, TypeError):
        pass
    
    return stripped


def parse_nested_key(key):
    """Parse a dotted key like 'notifications.notifActivite' into a list of keys."""
    return key.split('.')


def set_nested_value(doc, keys, value):
    """Set a value in a nested dictionary using a list of keys."""
    current = doc
    for key in keys[:-1]:
        if key not in current:
            current[key] = {}
        elif not isinstance(current[key], dict):
            current[key] = {}
        current = current[key]
    current[keys[-1]] = value


def csv_to_documents(filepath):
    """Convert a CSV file to a list of MongoDB documents."""
    documents = []
    
    with open(filepath, 'r', encoding='utf-8-sig') as f:
        reader = csv.DictReader(f)
        
        for row in reader:
            doc = {}
            for key, value in row.items():
                if key is None or key.strip() == '':
                    continue
                parsed_value = parse_value(value)
                keys = parse_nested_key(key)
                set_nested_value(doc, keys, parsed_value)
            
            # Ensure _id is an ObjectId if present
            if '_id' in doc and isinstance(doc['_id'], str):
                try:
                    doc['_id'] = ObjectId(doc['_id'])
                except:
                    pass
            
            documents.append(doc)
    
    return documents


def get_collection_name(filename):
    """Extract collection name from filename like 'kidora_test.users.csv' -> 'users'."""
    basename = os.path.basename(filename)
    # Remove .csv extension
    name = basename.rsplit('.csv', 1)[0]
    # Remove 'kidora_test.' prefix if present
    if name.startswith('kidora_test.'):
        name = name[len('kidora_test.'):]
    return name


def import_csv(filepath, collection, dry_run=False, drop=False):
    """Import a single CSV file into a MongoDB collection."""
    print(f"  Reading {filepath}...")
    documents = csv_to_documents(filepath)
    
    if not documents:
        print(f"  No documents found in {filepath}")
        return 0
    
    print(f"  Found {len(documents)} documents")
    
    if dry_run:
        print(f"  [DRY-RUN] Would insert {len(documents)} documents into '{collection.name}'")
        return len(documents)
    
    if drop:
        collection.delete_many({})
        print(f"  Dropped all existing documents in '{collection.name}'")
    
    try:
        # Use ordered=False to skip duplicates and continue
        result = collection.insert_many(documents, ordered=False)
        print(f"  Inserted {len(result.inserted_ids)} documents into '{collection.name}'")
        return len(result.inserted_ids)
    except errors.BulkWriteError as e:
        # Some documents may have been inserted, some may have failed (duplicates)
        inserted = e.details.get('nInserted', 0)
        write_errors = e.details.get('writeErrors', [])
        duplicate_count = sum(1 for err in write_errors if err.get('code') == 11000)
        other_errors = len(write_errors) - duplicate_count
        
        print(f"  Inserted {inserted} documents into '{collection.name}'")
        if duplicate_count > 0:
            print(f"  Skipped {duplicate_count} duplicate documents (already exist)")
        if other_errors > 0:
            print(f"  Encountered {other_errors} other errors")
        return inserted
    except Exception as e:
        print(f"  ERROR importing {filepath}: {e}")
        return 0


def main():
    parser = argparse.ArgumentParser(description='Import CSV files into MongoDB')
    parser.add_argument('--dry-run', action='store_true', help='Dry run - do not actually insert')
    parser.add_argument('--csv-dir', default='/opt/data_automation/csv', 
                        help='Directory containing CSV files (default: /opt/data_automation/csv)')
    parser.add_argument('--drop', action='store_true', help='Drop collections before importing (clean re-import)')
    args = parser.parse_args()
    
    # MongoDB connection parameters from environment
    mongo_host = os.environ.get('MONGO_HOST', 'localhost')
    mongo_port = int(os.environ.get('MONGO_PORT', '27017'))
    mongo_user = os.environ.get('MONGO_USER', '')
    mongo_password = os.environ.get('MONGO_PASSWORD', '')
    mongo_db = os.environ.get('MONGO_DB', 'kidora')
    mongo_auth_db = os.environ.get('MONGO_AUTH_DB', 'admin')
    
    # Connect to MongoDB
    if mongo_user and mongo_password:
        encoded_user = quote_plus(mongo_user)
        encoded_password = quote_plus(mongo_password)
        uri = f"mongodb://{encoded_user}:{encoded_password}@{mongo_host}:{mongo_port}/{mongo_db}?authSource={mongo_auth_db}"
    else:
        uri = f"mongodb://{mongo_host}:{mongo_port}/{mongo_db}"
    
    print(f"Connecting to MongoDB at {mongo_host}:{mongo_port}, database: {mongo_db}")
    
    try:
        client = MongoClient(uri, serverSelectionTimeoutMS=10000)
        # Test connection
        client.admin.command('ping')
        print("Successfully connected to MongoDB")
    except Exception as e:
        print(f"ERROR: Could not connect to MongoDB: {e}")
        sys.exit(1)
    
    db = client[mongo_db]
    
    # Find all CSV files
    csv_pattern = os.path.join(args.csv_dir, 'kidora_test.*.csv')
    csv_files = sorted(glob.glob(csv_pattern))
    
    if not csv_files:
        print(f"No CSV files found matching pattern: {csv_pattern}")
        sys.exit(1)
    
    print(f"Found {len(csv_files)} CSV files to import")
    print()
    
    total_inserted = 0
    total_found = 0
    
    for filepath in csv_files:
        collection_name = get_collection_name(filepath)
        collection = db[collection_name]
        
        print(f"[{collection_name}]")
        count = import_csv(filepath, collection, args.dry_run, drop=args.drop)
        total_inserted += count
        total_found += len(csv_to_documents(filepath))
        print()
    
    if args.dry_run:
        print(f"DRY-RUN COMPLETE: Would insert {total_inserted} documents across {len(csv_files)} collections")
    else:
        print(f"IMPORT COMPLETE: Inserted {total_inserted} documents across {len(csv_files)} collections")
    
    client.close()


if __name__ == '__main__':
    main()