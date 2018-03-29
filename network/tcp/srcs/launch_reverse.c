/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   launch_reverse.c                                   :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: root </var/mail/root>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/24 17:46:59 by root              #+#    #+#             */
/*   Updated: 2014/06/29 15:21:16 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcproxy.h"
#include "tcp.h"
#include <stdlib.h>
#include <sys/select.h>
#include <stdio.h>
#include <unistd.h>
#include <sys/time.h>

int					ft_select(fd_set *rfd, int fds[], int verbose)
{
	struct timeval	tv;
	size_t			i;
	int				maxfd;

	tv.tv_sec = 0;
	tv.tv_usec = 500000;

	FD_ZERO(rfd);
	maxfd = 0;
	i = 0;
	while (fds[i] != -1) {
		if (fds[i] > maxfd) {
			maxfd = fds[i] + 1;
		}
		FD_SET(fds[i], rfd);
	i++;
	}

	if ((select(maxfd + 1, rfd, NULL, NULL, &tv)) == -1) {
		if (verbose) {
			perror("select()");
		}
		return (-1);
	}
	return (0);
}

int					launch_reverse(char *addr, char *port, int verbose)
{
	struct timeval	timeout;
	int				fds[2];
	fd_set			rfd;
	int				ret;

	timeout.tv_usec = 0;
	timeout.tv_sec = 5;
	if ((master_sockfd = tcp_connect(addr, port, &timeout, verbose)) == -1) {
		if (verbose) {
			dprintf(2, "error: could not connect to host %s on port %s\n", addr, port);
		}
		return (EXIT_FAILURE);
	}

	fds[0] = master_sockfd;
	fds[1] = -1;
	while (1) {
		if (ft_select(&rfd, fds, verbose)) {
			return (EXIT_FAILURE);
		}
		if (FD_ISSET(master_sockfd, &rfd)) {
			if (process_request(master_sockfd, verbose)) {
				return (1);
			}
		}
	}

	close(master_sockfd);
	return (0);
}
