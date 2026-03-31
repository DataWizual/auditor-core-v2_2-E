"""
Entry point launcher — NOT compiled by build_cython.py.
Imports orchestrator (works as .py in dev or .so in client builds)
and delegates to its Click CLI entry point.
"""
from orchestrator import main

if __name__ == "__main__":
    main()
