/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tcp_listen.c                                       :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/05/11 18:09:13 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/27 02:41:15 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdint.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netdb.h>
#include <unistd.h>
#include <string.h>
#include <stdio.h>
#include <stdlib.h>
#include <errno.h>

int						tcp_listen(char *port, int backlog, int verbose, int flags)
{
	int					sockfd;
	struct addrinfo		hints;
	struct addrinfo		*servinfo;
	struct addrinfo		*p;
	int					rv;
	int					yes;
	char				*error;

	yes = 1;
	memset(&hints, 0, sizeof hints);
	hints.ai_family = AF_INET;
	hints.ai_socktype = SOCK_STREAM;
	hints.ai_flags = flags;
	if ((rv = getaddrinfo(NULL, port, &hints, &servinfo)) != 0)
	{
		if (verbose) {
			dprintf(2, "getaddrinfo(): %s\n", gai_strerror(rv));
		}
		return (-1);
	}
	for (p = servinfo; p != NULL; p = p->ai_next)
	{
		if ((sockfd = socket(p->ai_family, p->ai_socktype,
							 p->ai_protocol)) == -1)
		{
			if (verbose) {
				perror("socket()");
			}
			continue ;
		}

		if (setsockopt(sockfd, SOL_SOCKET, SO_REUSEADDR, &yes,
					   sizeof(int)) == -1)
		{
			if (verbose) {
				perror("setsockopt()");
			}
			exit(1);
		}

		if (bind(sockfd, p->ai_addr, p->ai_addrlen) == -1)
		{
			close(sockfd);
			continue ;
		}

		break;
	}

	if (p == NULL)
	{
		if (verbose) {
			perror("bind()");
		}
		return (-2);
	}

	freeaddrinfo(servinfo);
	if (listen(sockfd, backlog) == -1)
	{
		if (verbose) {
			perror("listen()");
		}
		close(sockfd);
		return (-3);
	}
	if (verbose) {
		dprintf(1, "server listening on port %s - backlog %d\n", port, backlog);
	}

	return (sockfd);
}
