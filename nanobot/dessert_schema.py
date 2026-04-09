"""Schema definitions for nanobot config (Version 1)."""
from typing import Dict, List, Optional
from pydantic import BaseModel

class MCPServerConfig(BaseModel):
    """Minimal MCP server config."""
    command: str
    args: List[str]
    env: Dict[str, str] = {}