import pytest
import subprocess
from unittest.mock import patch
from pandoc_fzf import (
    get_possible_formats,
    let_user_choose_format,
    get_clipboard,
    set_clipboard,
    run_pandoc_command,
    run_pandoc,
)
import typer


@pytest.fixture
def mock_subprocess_run():
    with patch("subprocess.run") as mock_run:
        yield mock_run


@pytest.fixture
def mock_iterfzf():
    with patch("pandoc_fzf.iterfzf") as mock:
        yield mock


@pytest.fixture
def mock_pyperclip():
    with patch("pandoc_fzf.pyperclip") as mock:
        yield mock


def test_get_possible_formats(mock_subprocess_run):
    mock_subprocess_run.return_value.stdout = "format1\nformat2\nformat3"
    assert get_possible_formats() == ["format1", "format2", "format3"]


def test_get_possible_formats_error(mock_subprocess_run):
    mock_subprocess_run.side_effect = subprocess.CalledProcessError(1, "cmd")
    with pytest.raises(typer.Exit):
        get_possible_formats()


def test_let_user_choose_format(mock_iterfzf):
    mock_iterfzf.return_value = "chosen_format"
    assert let_user_choose_format(["format1", "format2"]) == "chosen_format"


def test_let_user_choose_format_none(mock_iterfzf):
    mock_iterfzf.return_value = None
    assert let_user_choose_format(["format1", "format2"]) is None


def test_get_clipboard(mock_pyperclip):
    mock_pyperclip.paste.return_value = "clipboard content"
    assert get_clipboard() == "clipboard content"


def test_set_clipboard(mock_pyperclip):
    set_clipboard("new content")
    mock_pyperclip.copy.assert_called_once_with("new content")


def test_run_pandoc_command(mock_subprocess_run):
    mock_subprocess_run.return_value.stdout = "converted text"
    result = run_pandoc_command("markdown", "html", "# Hello")
    assert result == "converted text"
    mock_subprocess_run.assert_called_once_with(
        ["pandoc", "-f", "markdown", "-t", "html"],
        input="# Hello",
        capture_output=True,
        text=True,
        check=True,
    )


def test_run_pandoc_command_error(mock_subprocess_run):
    mock_subprocess_run.side_effect = subprocess.CalledProcessError(1, "cmd")
    with pytest.raises(typer.Exit):
        run_pandoc_command("markdown", "html", "# Hello")


@pytest.mark.parametrize(
    "in_format,out_format,clipboard_content,pandoc_output",
    [
        ("markdown", "html", "# Hello", "<h1>Hello</h1>"),
        ("html", "latex", "<p>Test</p>", "\\textbf{Test}"),
    ],
)
def test_run_pandoc(
    mock_subprocess_run,
    mock_iterfzf,
    mock_pyperclip,
    in_format,
    out_format,
    clipboard_content,
    pandoc_output,
):
    mock_subprocess_run.return_value.stdout = "format1\nformat2\nformat3"
    mock_iterfzf.side_effect = [in_format, out_format]
    mock_pyperclip.paste.return_value = clipboard_content
    mock_subprocess_run.return_value.stdout = pandoc_output

    with patch("pandoc_fzf.typer.echo") as mock_echo:
        run_pandoc()

    mock_pyperclip.copy.assert_called_once_with(pandoc_output)
    mock_echo.assert_called_with(
        f"Command executed: pandoc -f {in_format} -t {out_format}"
    )


def test_run_pandoc_no_input_format(mock_subprocess_run, mock_iterfzf, mock_pyperclip):
    mock_subprocess_run.return_value.stdout = "format1\nformat2\nformat3"
    mock_iterfzf.side_effect = [None, "html"]

    with pytest.raises(typer.Exit):
        run_pandoc()


def test_run_pandoc_no_output_format(mock_subprocess_run, mock_iterfzf, mock_pyperclip):
    mock_subprocess_run.return_value.stdout = "format1\nformat2\nformat3"
    mock_iterfzf.side_effect = ["markdown", None]

    with pytest.raises(typer.Exit):
        run_pandoc()


def test_run_pandoc_empty_clipboard(mock_subprocess_run, mock_iterfzf, mock_pyperclip):
    mock_subprocess_run.return_value.stdout = "format1\nformat2\nformat3"
    mock_iterfzf.side_effect = ["markdown", "html"]
    mock_pyperclip.paste.return_value = ""

    with pytest.raises(typer.Exit):
        run_pandoc()
