import sys
import yaml
from axolotl.utils.training import train
from axolotl.utils.config import merge_config_with_args, sanitize_config

def load_config_manual(config_path):
    with open(config_path, "r") as f:
        raw_cfg = yaml.safe_load(f)
    cfg = merge_config_with_args(raw_cfg, [])
    cfg = sanitize_config(cfg)
    return cfg

if __name__ == "__main__":
    if "--config" not in sys.argv:
        print("Usage: train.py --config path/to/config.yml")
        sys.exit(1)

    config_index = sys.argv.index("--config") + 1
    config_path = sys.argv[config_index]
    cfg = load_config_manual(config_path)
    train(cfg)
