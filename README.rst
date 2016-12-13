Mirantis OSS Tooling - Single Node Deployments
==============================================

The `oss-lab` repository provides scripts and configuration files to simplify
a single node deployment of Mirantis Operational Support System Tooling,
or OSS Tooling. This type of deployment is very usefull for demonstrative and
development purposes.

Environment Requirements
------------------------

`oss-lab` was tested only on the operating system Ubuntu 16.04 LTS
(Xenial Xerus) 64 bit with the following components:

==============  ==================  ==============================
Component       Recomended Version  Installation Instructions
==============  ==================  ==============================
docker          1.12.3 or later     `Docker Installation`_
docker-compose  1.9.0 or later      `Docker Compose Installation`_
==============  ==================  ==============================

.. _Docker Installation: https://docs.docker.com/engine/installation/linux/ubuntulinux/
.. _Docker Compose Installation: https://docs.docker.com/compose/install/#/install-using-pip

The current user have to in the `docker` group to be able to connect to docker.

Quickstart
----------

1. Clone `oss-lab`
~~~~~~~~~~~~~~~~~~

To start working with `oss-lab` the source repository have to be clonned on
the host which will be used for the deployment:

    ::

      git clone https://github.com/seecloud/oss-lab.git

And then change the current directory:

    ::

      cd oss-lab

2. Install Requirements
~~~~~~~~~~~~~~~~~~~~~~~

If the host already meets the requirements, then skip this step.

If there is already installed `docker` but not `docker-compose` run
the following script:

    ::

      scripts/install.sh

Otherwise, to install `docker` and `docker-compose` and add the current use
into the `docker` group, run the following script:

    ::

      scripts/setup.sh

.. note::
    This script also changes some sysctl settings.

.. warning::
    This script requires root privileges and uses `sudo` to obtain them.


3. Create Configuration for OSS Tooling
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Creating configuration files for OSS Tooling services consist of two steps. At
first, all appropriate variables have to be set in the `variables` file,
by default it contains the following parameters:

    ::

      OPENSTACK_IP=172.16.169.31
      ELASTICSEARCH_LOGS_IP=172.16.169.4

Where parameters are:

=====================  =======================================================
Parameter              Description
=====================  =======================================================
OPENSTACK_IP           An address of public API endpoint of OpenStack.
ELASTICSEARCH_LOGS_IP  An address of Elasticsearch with filtered log files of
                       OpenStack Services, such as Nova, Neutron and etc.
=====================  =======================================================

At second, after changing `variables` each time run the following script to
create a set of configuration files:

    ::

      scripts/configure.sh

By default all configuration files are created under
the `projcts/oss/` directory.

4. Source labrc
~~~~~~~~~~~~~~~

The labrc script sets appropriate environment variables which are used in
docker compose configuration files. `labrc` have to be sourced at least once
before to use `docker-compose`, to do that run the following command:

    ::

      source labrc

`labrc` supports to specify bind address and ports for `devops-portal` if
the default values are not suitable for some reason.

The usage of `labrc` looks like:

    ::

      [ADDRESS=<IP>] [HTTP_PORT=<port>] [HTTPS_PORT=<port>] source labrc

The list of supported parameters:

===========  =============
Parameter    Default Value
===========  =============
ADDRESS      0.0.0.0
HTTP_PORT    80
HTTPS_PORT   443
===========  =============

For example, to change default ports:

    ::

      HTTP_PORT=8000 HTTPS_PORT=8443 source labrc

`labrc` remembers all specified parameters and you should not specify them in
the next time if you do not want to change them, specify parameters only when
you want to change them. These parameters are stored in the `projects/oss/.env`
file with the `LABRC_` prefix.


5. Run Elasticsearch
~~~~~~~~~~~~~~~~~~~~

Run the following command to start `elasticsearch` which will be used by all
backend services:

    ::

      docker-compose -f infra-compose.yml up -d

6. Run OSS Tooling services
~~~~~~~~~~~~~~~~~~~~~~~~~~~

OSS Tooling services are described in the separate file `docker-compose.yml` to
be able easily manage them without affecting `elasticsearch`, to start all of
them at one run the following command:

    ::

      docker-compose up -d

The services will be started right after pulling images from `Docker Hub`_.

Then, by default DevOps Portal will be available at `http://HOST_IP/` where
HOST_IP is an accessable IP address of the host which was used for
the deployment.

.. note::
    The setup.sh script does not configure iptables to pass 80/tcp and 443/tcp
    by default. It have to be configured manually.

.. _Docker Hub: https://hub.docker.com/u/seecloud/

Multiple Simultaneous Deployments
---------------------------------

`labrc` supports to deploy several sets of OSS Tooling services which can
differ by settings or binding ports for `devops-portal`.

Create Specific Configurations
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

To create separate sets of configurations run the `configuration.sh` script
with the `-p` flag to choose a name for this set and then be able to refer on
it later. An alternative set of variables can be specified by the `-f` flag and
have to be created with the same set of parameters as the default `variables`
file.

E.g. to create a separate set of configs with the `dev0_variables` file as
a source of variables file and name it as `dev0`, run the following command:

    ::

      scripts/configure.sh -p dev0 -f dev0_variables

You have to specify `dev0` as the first positional argument for `labrc` to be
able to use `docker-compose` with this alternative set of configuration files
to spawn a separate set of containers.

The `elasticsearch` data is also separated for different deployments and is
located at `projects/<name>/data`.

Source labrc
~~~~~~~~~~~~

Use `labrc` to switch between configurations, e.g. to switch on
the `dev0` configuration:

    ::

      source labrc dev0

And to switch back on the default `oss`:

    ::

      source labrc

Deploy Services from Specific Tags
----------------------------------

To deploy particular services from specific tags specify the `TAG` environment
variable before to run `docker-compose`, by default the `latest` tag is used.
For example, to run the `health-api` and `health-collector` from the `demo` tag
run the following command:

    ::

      TAG=demo docker-compose up -d health-api health-collector

If this tag is not available locally, then it will be pulled.

Destroy Deployment
------------------

Services can be stopped and killed by the following command:

    ::

      docker-compose down

They are all stateless and all data is stored in `elasticsearch`, to stop and
kill `elasticsearch`:

    ::

      docker-compose -f infra-compose.yml down

The data of `elasticsearch` will be available after its stop and it is located
at `projects/oss/data`.
