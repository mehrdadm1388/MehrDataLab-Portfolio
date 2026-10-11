# =========================================================
#  Data Engineering Portfolio Manager
# =========================================================

class Member:
    """یک عضو تیم مهندسی داده"""
    def __init__(self, name, role):
        self.name = name
        self.role = role

    def __str__(self):
        return f"{self.name} ({self.role})"

    def __repr__(self):
        return f"Member({self.name!r}, {self.role!r})"


class Task:
    """یک تسک در پایپ‌لاین داده"""
    def __init__(self, name, operation, duration_min):
        self.name = name
        self.operation = operation      # مثلا: extract, transform, load
        self.duration_min = duration_min

    def __str__(self):
        return f"Task[{self.operation}] {self.name} ({self.duration_min} min)"

    def __repr__(self):
        return f"Task({self.name!r}, {self.operation!r}, {self.duration_min!r})"


class Dataset:
    """یک دیتاست که در گزارش‌ها استفاده می‌شود"""
    def __init__(self, name, rows, columns):
        self.name = name
        self.rows = rows
        self.columns = columns

    def __str__(self):
        return f"{self.name}: {self.rows:,} rows × {self.columns} cols"

    def __repr__(self):
        return f"Dataset({self.name!r}, rows={self.rows}, cols={self.columns})"


# ---------------------------------------------------------
#  کلاس‌های اصلی خواسته‌شده
# ---------------------------------------------------------

class Team:
    def __init__(self, members):
        self.members = list(members)

    def add_member(self, member):
        self.members.append(member)

    def get_names(self):
        return [m.name for m in self.members]

    def count(self):
        return len(self.members)

    def __str__(self):
        return f"Team({self.count()} members: {', '.join(self.get_names())})"


class Report:
    def __init__(self, datasets):
        self.datasets = list(datasets)

    def total_rows(self):
        return sum(d.rows for d in self.datasets)

    def get_names(self):
        return [d.name for d in self.datasets]

    def __str__(self):
        return (f"Report({len(self.datasets)} datasets, "
                f"total rows = {self.total_rows():,})")


class Pipeline:
    def __init__(self, tasks):
        self.tasks = list(tasks)

    def total_duration(self):
        return sum(t.duration_min for t in self.tasks)

    def get_operations(self):
        return [t.operation for t in self.tasks]

    def run(self):
        print("  ▶ Running pipeline...")
        for t in self.tasks:
            print(f"     - {t}")

    def __str__(self):
        return (f"Pipeline({len(self.tasks)} tasks, "
                f"total = {self.total_duration()} min)")


class Portfolio:
    def __init__(self, projects):
        # projects: dict  ->  {نام پروژه: {"team": Team, "pipeline": Pipeline, "report": Report}}
        self.projects = projects

    def get_project_names(self):
        return list(self.projects.keys())

    def find_by_pipeline_operation(self, operation):
        result = []
        for name, data in self.projects.items():
            if operation in data["pipeline"].get_operations():
                result.append(name)
        return result

    def summary(self):
        print("=" * 55)
        print("         DATA ENGINEERING PORTFOLIO SUMMARY")
        print("=" * 55)
        for name, data in self.projects.items():
            print(f"\n📦 Project: {name}")
            print(f"   {data['team']}")
            print(f"   {data['pipeline']}")
            print(f"   {data['report']}")
        print("\n" + "=" * 55)
        print(f"Total projects: {len(self.projects)}")
        print("=" * 55)


# ---------------------------------------------------------
#  ساخت داده‌های نمونه
# ---------------------------------------------------------

# --- تیم‌ها ---
team_alpha = Team([
    Member("Ali",   "Data Engineer"),
    Member("Sara",  "Data Analyst"),
    Member("Reza",  "ML Engineer"),
])

team_beta = Team([
    Member("Mina",  "Data Engineer"),
    Member("Omid",  "BI Developer"),
])

# --- پایپ‌لاین‌ها ---
pipeline_sales = Pipeline([
    Task("read_csv",       "extract",   5),
    Task("clean_nulls",    "transform", 12),
    Task("join_customers", "transform", 8),
    Task("load_to_dw",     "load",      6),
])

pipeline_logs = Pipeline([
    Task("read_kafka",     "extract",   3),
    Task("parse_json",     "transform", 10),
    Task("aggregate",      "transform", 7),
    Task("write_parquet",  "load",      4),
])

# --- گزارش‌ها ---
report_sales = Report([
    Dataset("sales_2024",    1_250_000, 18),
    Dataset("customers",       320_000, 12),
])

report_logs = Report([
    Dataset("app_logs",      5_400_000, 9),
    Dataset("error_events",    180_000, 6),
])

# --- پورتفولیو ---
portfolio = Portfolio({
    "Sales Analytics Platform": {
        "team": team_alpha,
        "pipeline": pipeline_sales,
        "report": report_sales,
    },
    "Log Processing System": {
        "team": team_beta,
        "pipeline": pipeline_logs,
        "report": report_logs,
    },
})


# ---------------------------------------------------------
#  اجرای برنامه
# ---------------------------------------------------------

if __name__ == "__main__":
    # 1) خلاصه پورتفولیو
    portfolio.summary()

    # 2) اجرای پایپ‌لاین پروژه اول
    print("\n🚀 Executing first project pipeline:")
    first_project = portfolio.get_project_names()[0]
    portfolio.projects[first_project]["pipeline"].run()

    # 3) جستجو بر اساس نوع عملیات
    print("\n🔎 Projects that have an 'extract' task:")
    print("   ", portfolio.find_by_pipeline_operation("extract"))

    # 4) جمع کل ردیف‌های دیتاست‌ها در کل پورتفولیو
    total = sum(
        data["report"].total_rows()
        for data in portfolio.projects.values()
    )
    print(f"\n📊 Total rows across all reports: {total:,}")