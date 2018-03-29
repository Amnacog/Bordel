/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   launch_bridge.c                                    :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/25 17:18:05 by aguilbau          #+#    #+#             */
/*   Updated: 2014/11/26 18:28:24 by nsaintot         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcp.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <netdb.h>

int						process_accept(int sockfd, char *port, int verbose)
{
	int					cl_sockfd;
	socklen_t			cli_len;
	struct sockaddr_in	cli;
	char				addr[INET_ADDRSTRLEN];

	cli_len = sizeof(cli);
	if ((cl_sockfd = accept(sockfd, (struct sockaddr *)&cli, &cli_len)) == -1) {
		if (verbose) {
			perror("accept()");
		}
		return (-1);
	}
	inet_ntop(AF_INET, &(cli.sin_addr), addr, INET_ADDRSTRLEN);
	if (verbose) {
		dprintf(1, "new connection from %s on %s\n", addr, port);
	}
	return (cl_sockfd);
}

int						launch_bridge(char *port1, char *port2, char *cmd, int verbose, int public)
{
	int					master;
	int					slave;
	int					cl_master;
	int					cl_slave;
	struct timeval		timeout;
	int					fds[3];
	fd_set				rfd;

	if ((master = tcp_listen(port1, 1, verbose, AI_PASSIVE)) < 0) {
		return (1);
	}
	if (public) {
		public = AI_PASSIVE;
	} else {
		public = 0;
	}
	if ((slave = tcp_listen(port2, 1, verbose, public)) < 0) {
		return (1);
	}

	timeout.tv_usec = 0;
	timeout.tv_sec = 5;
	fds[0] = master;
	fds[1] = slave;
	fds[2] = -1;

	cl_master = -1;
	cl_slave = -1;
	write(cl_master, "CONNECT 10.52.1.11:443", strlen("CONNECT 10.52.1.11:443"));
	while (1) {
		if (ft_select(&rfd, fds, verbose)) {
			return (EXIT_FAILURE);
		}
		if (cl_master == -1) {
			if (FD_ISSET(master, &rfd)) {
				if ((cl_master = process_accept(master, port1, verbose)) == -1) {
					return (EXIT_FAILURE);
				}
			}
		}
		if (cl_slave == -1) {
			if (FD_ISSET(slave, &rfd)) {
				if ((cl_slave = process_accept(slave, port2, verbose)) == -1) {
					return (EXIT_FAILURE);
				}
			}
		}
		if (cl_master != -1 && cl_slave != -1) {
			if (verbose) {
				dprintf(1, "launching bridge\n");
			}
			if (bridge(cl_master, cl_slave) < 0) {
				if (verbose) {
					dprintf(1, "connection closed on master, shutting down\n");
				}
				return (0);
			}
			if (verbose) {
				dprintf(1, "connection closed on slave\n");
			}
			cl_slave = -1;
			usleep(500000);
		}
	}
	return (0);
}
