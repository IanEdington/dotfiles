import re
from collections import Counter

LINE_RE = re.compile(r"^(?P<ts>\S+) (?P<level>[A-Z]+) (?P<msg>.*)$")


def parse_line(line):
    match = LINE_RE.match(line.strip())
    if not match:
        return None
    return match.groupdict()


def level_counts(lines):
    counts = Counter()
    for line in lines:
        parsed = parse_line(line)
        if parsed:
            counts[parsed["level"]] += 1
    return counts
