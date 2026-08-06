from .log_parser import level_counts


def summary(lines):
    counts = level_counts(lines)
    total = sum(counts.values())
    return {"total": total, "by_level": dict(counts)}
