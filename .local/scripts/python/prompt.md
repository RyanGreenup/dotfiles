You will be given a prompt and you will write an example given that prompt.

Below are examples of prompts and the expected output.

## Examples

### 1
### Prompt
Explain how to write a main function in Python

### Response
To write a main function in *Python*, define it as any other function but call it like so:



```python
if __name__ == '__main__':
    main()
```

This ensures the main function only runs when the script is executed rather than imported. When imported `__name__` becomes the name of the file (without the extension), when executed, `__name__` becomes `__main__`.

Putting it all together:


```python
#!/usr/bin/env python3
# Path: path/to/your_script.py
# -*- coding: utf-8 -*-

def main(args):
    """
    The core function that encapsulates all tasks performed by this script.
    Args can be parsed during runtime using the argparse module.
    """
    pass  # Your core code goes here

if __name__ == "__main__":
    main()
```

### 2

#### Prompt
Explain how to create a second rust file with functions and import it into another.
#### Response
In Rust, you can create a second file with functions and bring the functions into scope (import them) into another file by using the `mod` keyword.

For example, let's say you have a file named `my_functions.rs` in the same directory as your `main.rs` file. The `my_functions.rs` file could look like this:

```rust
// my_functions.rs
pub fn print_hello() {
    println!("Hello, world!");
}
```

Then you can import these functions into your `main.rs` file using the `mod` keyword:

```rust
// main.rs
mod my_functions; // this will import my_functions.rs

fn main() {
    my_functions::print_hello(); // calling the imported function
}
```

Note:


    - `pub` must preceed functions that are not private, all functions are private by default.
        - This is to ensure that modules remain encapsulated and promotes the use of a stable API by drawing developer attention toward functions that should not change.
    - `::` is used to *dot in* to other modules, much like ***R*** or the `.` in *Python*.
    - **Nomenclature** Rust doesn't use the term *import*, instead a function is said to *brought into scope* using the `mod` keyword.


Below is the prompt for the next task:



