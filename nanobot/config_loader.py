"""Minimal config loader for nanobot-desserts (Version 1)."""
import json
from pathlib import Path
from typing import Any, Dict

class Config:
    """Simple config container."""
    def __init__(self):
        self.agents = type('obj', (object,), {'defaults': type('obj', (object,), {'model': ''})()})()
        self.providers = type('obj', (object,), {'custom': type('obj', (object,), {'api_key': '', 'api_base': ''})()})()
        self.gateway = type('obj', (object,), {'host': '0.0.0.0', 'port': 18790})()
        self.tools = type('obj', (object,), {'mcp_servers': {}})()
        self.channels = {}
    
    def model_dump(self, mode: str = "json", by_alias: bool = True) -> Dict[str, Any]:
        return {}

def load_config(path: Path) -> Config:
    """Load config from JSON file or return defaults."""
    config = Config()
    if path.exists():
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
            # TODO: populate config from data if needed
        except Exception:
            pass
    return config