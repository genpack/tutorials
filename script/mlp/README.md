# Event Prediction Platform Predictions and Describers

## Setting up

First, install dependencies with poetry:
```
poetry install
```
    
Then, use a system-specific command to install PyTorch, if you plan on using PyTorch models:

- On Windows:
  ```
  poetry run pip install torch==1.4.0 -f https://download.pytorch.org/whl/torch_stable.html
  ```
- On Linux and Mac OS:
  ```
  poetry install -E torch
  ```

We keep PyTorch's Windows version out of the pyproject.toml because it prevents us from being able to run `poetry lock`.
