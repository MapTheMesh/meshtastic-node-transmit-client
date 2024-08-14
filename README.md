# Meshtastic Node Transmit Client

---

## Description
This project is the client script that will be used to transmit your meshtastic node information and seen nodes to the server.  
Run the script as a service on a Linux/Unix based client, suggested be run every 30 minutes.  
This will transmit the node information and seen nodes to the server, to be stored in a the and displayed on the web page.

## Requirements
- Python 3.6+
- Pip
- [.jq (a lightweight and flexible command-line JSON processor)](https://stedolan.github.io/jq/)
- Meshtastic device
- Meshtastic Python CLI
- Meshtastic device connected to the client (USB, Bluetooth, or via HTTP)

## Installation
1. Clone the repository
2. Install the required python packages
```bash
pip install -r requirements.txt
```
3. Install jq (use the package manager of your choice, examples below)
   - Ubuntu
    ```bash
    sudo apt-get install jq
    ```
    - MacOS
    ```bash
    brew install jq
    ```
4. Copy the `.env.example` file to `.env` and fill in the required information
5. Run the script
```bash
bash run.sh
```

## Configuration
The configuration is done in the `.env` file.  
The only required configuration option is your API key, which can be found here - [Meshtastic Node Transmit Server](https://map.themesh.live/)

## License
This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details

## Acknowledgements
- [Meshtastic](https://meshtastic.org/)
- [Meshtastic Python CLI](https://github.com/meshtastic/python)

## Disclaimer
This project is not affiliated with or endorsed by the Meshtastic project.
