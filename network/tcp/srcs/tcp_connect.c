/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tcp_connect.c                                      :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: root </var/mail/root>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/22 19:47:36 by root              #+#    #+#             */
/*   Updated: 2014/06/27 02:38:59 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <netdb.h>
#include <unistd.h>
#include <sys/time.h>
#include <stdio.h>

int						tcp_connect(char *addr, char *port, struct timeval *timeout, int verbose)
{
	int					sockfd;
	struct addrinfo		hints, *servinfo;
	int					status;

	memset(&hints, 0, sizeof(hints));
	hints.ai_family = AF_UNSPEC;
	hints.ai_socktype = SOCK_STREAM;

	if ((status = getaddrinfo(addr, port, &hints, &servinfo) != 0)) {
		if (verbose) {
			dprintf(2, "getaddrinfo(): %s\n", gai_strerror(status));
		}
		return (-1);
	}

	if ((sockfd = socket(servinfo->ai_family, servinfo->ai_socktype, servinfo->ai_protocol)) == -1) {
		if (verbose) {
			perror("socket()");
		}
		return (-1);
	}

	if (timeout) {
		if (setsockopt(sockfd, SOL_SOCKET, SO_SNDTIMEO, timeout, sizeof(struct timeval)) != 0) {
			close(sockfd);
			if (verbose) {
				perror("setsockopt()");
			}
			return (-1);
		}
	}

	if (connect(sockfd, servinfo->ai_addr, servinfo->ai_addrlen) == -1) {
		close(sockfd);
		if (verbose) {
			perror("connect()");
		}
		return (-1);
	}

	freeaddrinfo(servinfo);
	return (sockfd);
}
