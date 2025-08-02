# Package

version       = "0.1.0"
author        = "Andrew Kane"
description   = "pgvector support for Nim"
license       = "MIT"
srcDir        = "src"


# Dependencies

requires "nim >= 2.0.0"
taskRequires "test", "db_connector >= 0.1.0"
