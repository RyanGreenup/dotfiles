You are tasked with producing a mathematical expression based on a description provided by the user, what follows is an example:

## Examples

### Input
Write the Fourier Transform in Markdown Mathematics using KaTeX

### Expected Output

$$
F(k) = \int_{-\infty}^{\infty} f(x) \cdot e^{-2 \pi i k x} \, dx
$$

### Input

Produce the following mathematical expression using Markdown Mathematics using KaTeX:

### Output

The \mathrm{Cov}ariance Matrix of a random vector $\mathbf{X} = [X_1, X_2, ..., X_n]$ can be represented as follows:

$$
\mathbf{\Sigma} = E[(\mathbf{X} - E[\mathbf{X}])(\mathbf{X} - E[\mathbf{X}])^\mathbf{T}]
$$

or in the expanded form:

$$
\mathbf{\Sigma} =
\begin{bmatrix}
\mathrm{Var}(X_1) & \mathrm{Cov}(X_1, X_2) & \cdots & \mathrm{Cov}(X_1, X_n) \\
\mathrm{Cov}(X_2, X_1) & \mathrm{Var}(X_2) & \cdots & \mathrm{Cov}(X_2, X_n) \\
\vdots & \vdots & \ddots & \vdots \\
\mathrm{Cov}(X_n, X_1) & \mathrm{Cov}(X_n, X_2) & \cdots & \mathrm{Var}(X_n) \\
\end{bmatrix}
$$

Where:
- $E[\mathbf{X}]$ is the expected value (mean) of $\mathbf{X}$.
- $\mathrm{Var}(X_i)$ is the variance of $X_i$.
- $\mathrm{Cov}(X_i, X_j)$ is the covariance between $X_i$ and $X_j$.
- $\mathbf{X}^\mathbf{T}$ is the transpose operation applied to some matrix $\mathbf{X}$.

### Input


here is the input:

The equation for the normal distribution

### Output

The equation for the normal distribution, also known as the Gaussian distribution, can be represented as follows:

$$
f(x \,|\, \mu, \sigma^2) = \frac{1}{\sqrt{2\pi\sigma^2}} \, e^{ -\frac{(x-\mu)^2}{2\sigma^2} }
$$

Where:
- $x$ is the variable.
- $\mu$ is the mean or expectation of the distribution.
- $\sigma^2$ is the variance.
- $\sigma$ is the standard deviation.

### Input
Explain the equation for the Laplace transform in Markdown Mathematics using KaTeX.

### Expected Output
The Laplace transform of a function f(t), defined for all real numbers t ≥ 0, can be represented as follows:

$$
F(s) = \int_{0}^{\infty} f(t) e^{-st}\,dt
$$

Where:
- $s$ is a complex number frequency parameter.
- $F(s)$ is the image of the original function $f(t)$
- $f(t)$ is the original function.

### Input
Define the equation for Poisson distribution in Markdown Mathematics with KaTeX.

### Output
The equation for the Poisson distribution can be represented as follows:

$$
P(k\,|\,\lambda) = \frac{\lambda^k e^{-\lambda}}{k!}
$$

Where:
- $k$ is the actual number of events.
- $\lambda$ is the average number of events per interval.
- $k!$ is the factorial of $k$.

### Input
Explain the equation for the eigenvector of a matrix using Markdown Mathematics using KaTeX.

### Output
The equation for the eigenvector of a square matrix $A$ can be represented as follows:

$$
A \mathbf{v} = \lambda \mathbf{v}
$$

Where:
- $A$ is a square matrix.
- $\mathbf{v}$ is an eigenvector of matrix $A$.
- $\lambda$ is the eigenvalue corresponding to the eigenvector $\mathbf{v}$.
### Input
What is the formula for a diagonalized matrix? Express this using matrices for:

### Output

$$
\mathbf{A} = \mathbf{P} \mathbf{D} \mathbf{P}^{-1}
$$

Where:

- $\mathbf{A}$:

    $\mathbf{A} =
    \begin{bmatrix}
        a_{1,1} & a_{1,2} & a_{1,3} & \ldots \\
        a_{2,1} & a_{2,2} & a_{2,3} & \ldots \\
        a_{3,1} & a_{3,2} & a_{3,3} & \ldots \\
        \vdots & \vdots & \vdots    & \ddots
    \end{bmatrix}$

- $\mathbf{D}$ is a diagonal matrix given by:

    $\begin{bmatrix}
    \begin{bmatrix} \left(\vec{x_1}\right)_{\left[1\right]}  \\ \left(\vec{x_1}\right)_{\left[2\right]} \\ \left(\vec{x_1}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \begin{bmatrix} \left(\vec{x_2}\right)_{\left[1\right]}  \\ \left(\vec{x_2}\right)_{\left[2\right]} \\ \left(\vec{x_2}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \begin{bmatrix} \left(\vec{x_3}\right)_{\left[1\right]}  \\ \left(\vec{x_3}\right)_{\left[2\right]} \\ \left(\vec{x_3}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \cdots
    \end{bmatrix}
    \begin{bmatrix}
    \lambda_1 & 0 & 0 & \ldots \\
    0 & \lambda_2 & 0 & \ldots \\
    0 & 0 & \lambda_3 & \ldots \\
    \vdots & \vdots & \vdots    & \ddots
    \end{bmatrix}$

See Equation $\left(\mathrm{eigen}\right)$

- $\mathbf{P} = \begin{bmatrix} \vec{x_1}  &   \vec{x_2}  &  \vec{x_3}  & \ldots \end{bmatrix}$ be the matrix of eigenvectors: $\mathbf{P}_{\left[i,j\right]} = \left(\vec{x}_j\right)_{\left[i\right]}$. This can be seen as a horizontal concatenation of the eigenvectors:

    $\mathbf{P} =
    \begin{bmatrix}
    \begin{bmatrix} \left(\vec{x_1}\right)_{\left[1\right]}  \\ \left(\vec{x_1}\right)_{\left[2\right]} \\ \left(\vec{x_1}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \begin{bmatrix} \left(\vec{x_2}\right)_{\left[1\right]}  \\ \left(\vec{x_2}\right)_{\left[2\right]} \\ \left(\vec{x_2}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \begin{bmatrix} \left(\vec{x_3}\right)_{\left[1\right]}  \\ \left(\vec{x_3}\right)_{\left[2\right]} \\ \left(\vec{x_3}\right)_{\left[3\right]}  \\ \vdots \end{bmatrix}   &
    \cdots
    \end{bmatrix}$
# User
You are tasked with producing a mathematical expression based on a description provided by the user, here is the description:
