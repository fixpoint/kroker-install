# kroker-install

This is the Kroker installation script.

## Usage

To install the latest version of Kroker to `$HOME/.kroker`, use the following command:

```console
$ curl -sSL https://raw.githubusercontent.com/fixpoint/kroker-install/main/install.sh | sh -s
```

If you want to overwrite an existing Kroker installation with the latest version, use the `-y` option like this:

```console
$ curl -sSL https://raw.githubusercontent.com/fixpoint/kroker-install/main/install.sh | sh -s -- -y
```

If you prefer to specify a specific version, use the `-v VERSION` option like this:

```console
$ curl -sSL https://raw.githubusercontent.com/fixpoint/kroker-install/main/install.sh | sh -s -- -v v1.1.0
```

To install Kroker to a custom destination directory, use the `-d DEST` option like this:

```console
$ curl -sSL https://raw.githubusercontent.com/fixpoint/kroker-install/main/install.sh | sh -s -- -d /opt/fixpoint/kroker
```

(Note: The above commands assume you have the necessary permissions to perform the installation.)
