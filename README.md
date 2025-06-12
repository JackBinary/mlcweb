# mlcweb

**mlcweb** is a lightweight launcher script that runs an [MLC LLM](https://mlc.ai/) model server and [Open WebUI](https://github.com/open-webui/open-webui) side-by-side in parallel, inside a self-managed Python virtual environment.

The intention is to make setting up an mlc-llm environment as painless as I can.

---

## 🚀 Features

- Automatically sets up a Python virtual environment at `~/.mlcweb/venv`
- Installs or updates:
  - `torch`, `torchvision`, `torchaudio`
  - `mlc-llm-nightly-cpu`, `mlc-ai-nightly-cpu`
  - `open-webui`
- Uses `mlc_llm serve` to launch your chosen model (default: Qwen3-8B)
- Opens [http://localhost:8080](http://localhost:8080) in your browser when ready
- Gracefully handles `Ctrl+C` to stop both processes

> **Note:** PyTorch CPU wheels are used because both MLC and Open WebUI require `torch` as a dependency, but actual model inference is handled via **Vulkan by MLC**, not PyTorch.

---

## 🧱 Prerequisites

Before installing, make sure your system has:

- **Python 3.11 or 3.12**
- **curl**
- [**Vulkan-compatible GPU + drivers**](https://linuxconfig.org/install-and-test-vulkan-on-linux)
- **xdg-open**

---

## 🛠 Installation

Run the following command to install the launcher into `/usr/local/bin/mlcweb`:

```bash
curl -fsSL https://raw.githubusercontent.com/JackBinary/mlcweb/refs/heads/main/install-mlcweb.sh | sudo bash
````

This will download the launcher script and make `mlcweb` available globally.

---

## 🧪 Usage

Run with the default model:

```bash
mlcweb
```

You can explore MLC-compatible models here:

👉 [https://huggingface.co/mlc-ai](https://huggingface.co/mlc-ai)

To use a different model:

```bash
mlcweb HF://mlc-ai/Qwen3-14B-q4f16_1-MLC
```

You can also pass additional arguments to mlc_llm (see [MLC Documentation](https://llm.mlc.ai/docs/deploy/rest.html#launch-the-server))

```bash
mlcweb HF://mlc-ai/Qwen3-32B-q4f16_1-MLC --overrides "tensor_parallel_shards=2"
```
> **Note:** You must always specify a model as the first argument. The script assumes the first argument is an alternate model.

---

## 📄 License

This project is licensed under the [Apache License 2.0](LICENSE).
