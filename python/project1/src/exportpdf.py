from pathlib import Path

BASE_DIR = Path(__file__).resolve().parent.parent

REPORT = BASE_DIR / "reports" / "report.txt"


def export_report(text):

    REPORT.parent.mkdir(
        parents=True,
        exist_ok=True
    )

    with open(
        REPORT,
        "w",
        encoding="utf-8"
    ) as file:

        file.write(text)

    print(f"Report saved successfully:\n{REPORT}")