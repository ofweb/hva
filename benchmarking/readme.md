# benchmarking

Very early bad wip

- `benchmarking.sh`: iterates all `.gguf` files in `LLAMA_MODELS`, binary-searches for optimal `-ncmoe` per model, runs a prompt, writes results to `benchmarking/results/<timestamp>.csv`
