"""Download the raw Lending Club 2007-2011 loan file.

Lending Club no longer hosts its public loan files, so this script pulls the
original LoanStats3a.csv (42,535 loans issued June 2007 - December 2011) from a
public mirror on GitHub and saves it to data/raw/.

Usage:
    python src/download_data.py
"""
from pathlib import Path
from urllib.request import urlretrieve

URL = (
    "https://raw.githubusercontent.com/h2oai/h2o-tutorials/master/"
    "training/sessions/richmond/LoanStats3a.csv"
)
ROOT = Path(__file__).resolve().parents[1]
DEST = ROOT / "data" / "raw" / "LoanStats3a.csv"


def main() -> None:
    DEST.parent.mkdir(parents=True, exist_ok=True)
    if DEST.exists():
        print(f"Already downloaded: {DEST}")
        return
    print(f"Downloading {URL} ...")
    urlretrieve(URL, DEST)
    print(f"Saved {DEST.stat().st_size / 1e6:.1f} MB to {DEST}")


if __name__ == "__main__":
    main()
