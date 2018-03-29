/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   parse_remote_addr.c                                :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/25 15:46:12 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/25 17:17:19 by aguilbau         ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcp.h"
#include "tcproxy.h"

int			parse_remote_addr(char *addr, char *port, char *args)
{
	int		i;
	int		j;

	i = 0;
	if (addr) {
		while (args[i] && args[i] != ':') {
			if (i > INET_ADDRSTRLEN) {
				return (1);
			}
			addr[i] = args[i];
			++i;
		}
		addr[i] = '\0';
		if (args[i] == '\0' || args[++i] == '\0')
			return (1);
	}

	if (port) {
		j = 0;
		while (args[i]) {
			if (j > PORT_MAXLEN) {
				return (1);
			}
			port[j] = args[i];
			++i;
			++j;
		}
		port[j] = '\0';
	}

	return (0);
}
