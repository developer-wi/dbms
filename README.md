# MySQL Master-Slave Replication Setup

This project sets up a MySQL master-slave replication environment using Docker. It includes configurations for both the master and slave databases, along with necessary scripts for initialization.

## Prerequisites

- Docker
- Docker Compose

## Directory Structure

├── docker-compose.yml
├── mysql
│ ├── master
│ │ ├── config
│ │ │ └── my.cnf
│ │ └── scripts
│ │ └── docker-entrypoint-master.sh
│ └── slave
│ ├── config
│ │ └── my.cnf
│ └── scripts
│ └── docker-entrypoint-slave.sh
└── run.sh

````

## Environment Variables

The following environment variables need to be defined in a `.env.dev` file:

- `MYSQL_ROOT_PASSWORD`: Password for the MySQL root user.
- `MYSQL_REPL_USER_ID`: Username for the replication user.
- `MYSQL_REPL_USER_PASSWORD`: Password for the replication user.
- `MYSQL_MASTER_HOST`: Hostname or IP address of the master database.
- `MYSQL_MASTER_PORT`: Port number for the master database.
- `MYSQL_USER_ID`: Username for the application user.
- `MYSQL_USER_PASSWORD`: Password for the application user.
- `MYSQL_DB`: Name of the database to be created.

## Setup Instructions

1. Clone the repository to your local machine.
2. Create a `.env.dev` file in the root directory and define the required environment variables.
3. Run the following command to start the services:

   ```bash
   ./run.sh
````

4. The master database will be accessible on port `13306`, and the slave database will be accessible on port `13307`.

## Scripts

- **Master Initialization Script**: `mysql/master/scripts/docker-entrypoint-master.sh`

  - Creates the replication user and grants necessary privileges.

- **Slave Initialization Script**: `mysql/slave/scripts/docker-entrypoint-slave.sh`
  - Configures the slave to connect to the master and sets up the database.

## Configuration

- The MySQL master and slave configurations can be found in the respective `my.cnf` files located in the `config` directories.

## Notes

- Ensure that the Docker daemon is running before executing the setup.
- The master and slave databases are configured to use the MariaDB image version `10.6.3-focal`.

## Troubleshooting

- If you encounter issues, check the logs of the containers using:

  ```bash
  docker-compose logs
  ```

- Ensure that the environment variables are correctly set in the `.env.dev` file.

## License

This project is licensed under the MIT License.
