import subprocess
from typing import List, Optional

import pyperclip
import typer
from iterfzf import iterfzf

app = typer.Typer()


def get_possible_formats() -> List[str]:
    """
    Returns a list of possible output formats by running pandoc.
    """
    try:
        result = subprocess.run(
            ["pandoc", "--list-output-formats"],
            capture_output=True,
            text=True,
            check=True,
        )
        return result.stdout.splitlines()
    except subprocess.CalledProcessError as e:
        typer.echo(f"Error obtaining formats: {e}")
        raise typer.Exit(code=1)


def let_user_choose_format(formats: List[str]) -> Optional[str]:
    """
    Allows the user to choose a format using fzf.
    """
    return iterfzf(formats)


def get_clipboard() -> str:
    """
    Fetches the content from the clipboard.
    """
    return pyperclip.paste()


def set_clipboard(text: str) -> None:
    """
    Sets the given text into the clipboard.
    """
    pyperclip.copy(text)


def run_pandoc_command(in_format: str, out_format: str, text: str) -> str:
    """
    Executes the pandoc command with given input and output formats.
    """
    command = ["pandoc", "-f", in_format, "-t", out_format]
    try:
        result = subprocess.run(
            command, input=text, capture_output=True, text=True, check=True
        )
        return result.stdout
    except subprocess.CalledProcessError as e:
        typer.echo(f"Error running pandoc: {e}")
        raise typer.Exit(code=1)


@app.command(name="run-pandoc")
def run_pandoc() -> None:
    """
    Converts text from clipboard using pandoc with user-selected input and output formats,
    and sets the result back to the clipboard.
    """
    formats = get_possible_formats()

    typer.echo("Choose the input format:")
    in_format = let_user_choose_format(formats)
    if not in_format:
        typer.echo("No input format selected.")
        raise typer.Exit(code=1)

    typer.echo("Choose the output format:")
    out_format = let_user_choose_format(formats)
    if not out_format:
        typer.echo("No output format selected.")
        raise typer.Exit(code=1)

    text = get_clipboard()
    if not text:
        typer.echo("Clipboard is empty.")
        raise typer.Exit(code=1)

    result = run_pandoc_command(in_format, out_format, text)
    set_clipboard(result)

    typer.echo(f"Command executed: pandoc -f {in_format} -t {out_format}")


if __name__ == "__main__":
    app()
