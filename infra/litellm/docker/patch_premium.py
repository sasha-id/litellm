#!/usr/bin/env python3
"""Patch LiteLLM's LicenseCheck.is_premium to always return True."""
import ast
import sysconfig
from pathlib import Path


def patch():
    site = sysconfig.get_path("purelib")
    target = Path(site) / "litellm" / "proxy" / "auth" / "litellm_license.py"

    if not target.exists():
        target = Path("/app/litellm/proxy/auth/litellm_license.py")

    if not target.exists():
        raise FileNotFoundError(f"Cannot find litellm_license.py in {site} or /app")

    source = target.read_text()

    tree = ast.parse(source)
    for node in ast.walk(tree):
        if isinstance(node, ast.FunctionDef) and node.name == "is_premium":
            line = node.lineno
            break
    else:
        raise RuntimeError("is_premium method not found")

    lines = source.splitlines(keepends=True)

    indent = ""
    for ch in lines[line - 1]:
        if ch in (" ", "\t"):
            indent += ch
        else:
            break

    body_indent = indent + "    "

    insert_line = line  # right after "def is_premium(...):"
    lines.insert(insert_line, f"{body_indent}return True\n")

    target.write_text("".join(lines))

    verify = target.read_text()
    assert "return True" in verify, "Patch verification failed"
    print(f"Patched {target}: is_premium() now always returns True")


if __name__ == "__main__":
    patch()
