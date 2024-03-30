#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-
#!/usr/bin/env python3
import typer

app = typer.Typer()


@app.command()
def hello(name: str):
    typer.echo(f"Hello {name}")


@app.command()
def goodbye(name: str):
    typer.echo(f"Goodbye {name}")

# Test for goodby


def test_goodbye():
    result = goodbye("World")
    assert result == "Goodbye World"


def test_hello():
    result = hello("World")
    assert result == "Hello World"


if __name__ == "__main__":
    app()
