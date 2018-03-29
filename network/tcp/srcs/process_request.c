/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   process_request.c                                  :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/25 15:30:19 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/26 23:50:59 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcp.h"
#include "tcproxy.h"
#include "stdfuns.h"
#include <sys/types.h>
#include <sys/uio.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdlib.h>
#include <string.h>

#define BUFF_SIZE		1024
#define CMD_NB			1

void					r_connect(char **av, int master, int verbose)
{
	int					slave;
	int					len;
	char	addr[INET_ADDRSTRLEN + 1];
	char	port[PORT_MAXLEN + 1];
	struct timeval	timeout;

	if (!av[1]) {
		return ;
	}

	parse_remote_addr(addr, port, av[1]);

	timeout.tv_usec = 0;
	timeout.tv_sec = 5;
	if ((slave = tcp_connect(addr, port, &timeout, 1)) == -1) {
		if (verbose) {
			dprintf(2, "error: could not connect to host %s on port %s\n", addr, port);
		}
		return ;
	}
	if (verbose) {
		dprintf(1, "connection to %s on port %s established\n", addr, port);
	}
	bridge(master, slave);
	if (verbose) {
		dprintf(1, "connection closed\n");
	}
}

int						process_request(int sockfd, int verbose)
{
	char				*cmd_names[CMD_NB + 1] = {"CONNECT", NULL};
	void				(*f[CMD_NB])(char **, int, int) = {r_connect};
	char				buffer[BUFF_SIZE];
	int					ret;
	char				**cmd;
	int					i;

	if ((ret = read(sockfd, buffer, BUFF_SIZE - 1)) <= 0) {
		close(sockfd);
		return (1);
	}

	if (buffer[ret - 1] == '\n') {
		buffer[ret - 1] = '\0';
	} else {
		buffer[ret] = '\0';
	}

	if (verbose) {
		dprintf(1, "got command: '%s'\n", buffer);
	}
	if ((cmd = ft_strsplit(buffer, ' ')) == NULL) {
		writen(sockfd, ERROR_500, STRLEN(ERROR_500));
		close(sockfd);
		return (1);
	}

	i = 0;
	while (cmd_names[i]) {
		if (!strcmp(cmd_names[i], cmd[i])) {
			f[i](cmd, sockfd, verbose);
			break ;
		}
		++i;
	}
	free_table(cmd);
	return (0);
}
