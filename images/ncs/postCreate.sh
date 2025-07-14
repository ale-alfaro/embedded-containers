#!/bin/bash
WORKSPACE_DIR="$1"
echo "🏗️ Post Create command"

function checkToolchain() {
    if ! command -v nrfutil &> /dev/null; then
        echo "⚠️ nrfutil could not be found"
        return 1
    else
        echo "✅ nrfutil is installed"
        nrfutil --version
    fi

    if ! command -v west &> /dev/null; then
        echo "⚠️ west could not be found"
        return 1
    else
        echo "✅ west is installed"
        west --version
    fi

    return 0
}

APPLICATION_DIR=${WORKSPACE_DIR}/application
DEPS_DIR=${WORKSPACE_DIR}/deps


function createWestWorkspace() {
    echo "Creating west workspace..."
    # Create a west workspace if it doesn't exist


    cat << EOF > "${APPLICATION_DIR}/west.yml"
        manifest:
            group-filter: [+unstable,-optional]
            remotes:
                - name: ncs
                url-base: https://github.com/nrfconnect
            projects:
                - name: sdk-nrf
                remote: ncs
                revision: v3.0.2
                path: nrf
                import:
                    path-prefix: deps
                    name-allowlist:
                    - cmsis
                    - hal_nordic
                    - mcuboot
                    - mbedtls
                    - nrfxlib
                    - segger
                    - zephyr
EOF

    west init -l "${APPLICATION_DIR}/west.yml" && \
    west update --narrow -o=--depth=1 && \
    west config zephyr.base "${DEPS_DIR}/zephyr" && \
    echo "West workspace initialized with manifest project: ${APPLICATION_DIR}/west.yml"
    echo "West workspace created."
}

function zephyrEnv() {
    echo "Creating zephyr-env.sh..."
    # Create zephyr-env.sh if it doesn't exist
    ZEPHYR_ENV_SH="$(west topdir)/$(west config zephyr.base)/zephyr-env.sh"
    echo "#!/bin/bash" > zephyr-env.sh
    echo "source <(nrfutil sdk-manager toolchain env --as-script --ncs-version ${NCS_VERSION})" >> zephyr-env.sh
    echo "source ${ZEPHYR_ENV_SH}" >> zephyr-env.sh
    echo "west zephyr-export" >> zephyr-env.sh
    chmod +x zephyr-env.sh
    echo "zephyr-env.sh created."

}


ENV_FILE=".devcontainer/.env"
echo "Running on local host"
echo "Load environment variables from ${ENV_FILE}"
if [ -f "$ENV_FILE" ]; then
    # Get absolute path of .env file
    ENV_FILE=$(realpath ${ENV_FILE})
    # Add loading of variables to ~/.bashrc
    echo "Add env file ${ENV_FILE} to ~/.bashrc"
    echo "### Load env variables" >> ~/.bashrc
    echo "# Added from postStartCommand.sh" >> ~/.bashrc
    echo "set -o allexport" >> ~/.bashrc
    echo "source ${ENV_FILE}" >> ~/.bashrc
    echo "set +o allexport" >> ~/.bashrc
    echo "### Load env variables" >> ~/.bashrc
else
    echo "$ENV_FILE does not exist."
    # exit 1
fi

checkToolchain

if [ ! -d "${containerWorkspaceFolder}/.west" ]; then
    echo "Initializing West workspace with NCS ${NCS_VERSION}..."
    mkdir -p "${APPLICATION_DIR}"
    mkdir -p "${DEPS_DIR}"
    cd "${APPLICATION_DIR}"
    createWestWorkspace
else
    echo "West workspace already exists."
fi

if [ ! -f "${APPLICATION_DIR}/zephyr-env.sh" ]; then
    echo "Creating zephyr-env.sh..."
    cd "${APPLICATION_DIR}"
    zephyrEnv
else
    echo "zephyr-env.sh already exists."
fi
echo "Post Create command completed."
