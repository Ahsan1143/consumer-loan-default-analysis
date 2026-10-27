"""Load the raw Lending Club file into SQLite and build the clean `loans` table.

Steps
1. Read data/raw/LoanStats3a.csv as text and stage it in table `loans_raw`.
2. Run sql/01_clean_loans.sql to type, filter and band the data into `loans`.
3. Export `loans` to data/processed/loans_clean.csv.

Usage:
    python src/build_database.py
"""
from pathlib import Path
import sqlite3

import pandas as pd

ROOT = Path(__file__).resolve().parents[1]
RAW = ROOT / "data" / "raw" / "LoanStats3a.csv"
DB = ROOT / "data" / "lending_club.db"
CLEAN_SQL = ROOT / "sql" / "01_clean_loans.sql"
PROCESSED = ROOT / "data" / "processed" / "loans_clean.csv"


def main() -> None:
    if not RAW.exists():
        raise SystemExit("Raw file missing - run `python src/download_data.py` first.")

    raw = pd.read_csv(RAW, dtype=str, low_memory=False)
    print(f"Raw rows read: {len(raw):,}")

    with sqlite3.connect(DB) as con:
        raw.to_sql("loans_raw", con, if_exists="replace", index=False)
        con.executescript(CLEAN_SQL.read_text())
        n = con.execute("SELECT COUNT(*) FROM loans").fetchone()[0]
        print(f"Clean `loans` table: {n:,} completed loans")
        PROCESSED.parent.mkdir(parents=True, exist_ok=True)
        pd.read_sql("SELECT * FROM loans", con).to_csv(PROCESSED, index=False)

    print(f"Database: {DB}")
    print(f"Processed CSV: {PROCESSED}")


if __name__ == "__main__":
    main()
