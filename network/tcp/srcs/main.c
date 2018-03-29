/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   main.c                                             :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: toni </var/mail/toni>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/24 05:22:59 by toni              #+#    #+#             */
/*   Updated: 2014/06/29 17:39:48 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcp.h"
#include "tcproxy.h"
#include <unistd.h>
#include <stdlib.h>
#include <stdio.h>

#define ARGS_FORMAT	"r:l:c:vdpk:"

static int	parse_bridge(char *port1, char *port2, char *args)
{
	int		i;
	int		j;

	i = 0;
	while (args[i] && args[i] != ':') {
		if (i > PORT_MAXLEN) {
			return (1);
		}
		port1[i] = args[i];
		++i;
	}
	port1[i] = '\0';
	if (args[i] == '\0' || args[++i] == '\0')
		return (1);

	j = 0;
	while (args[i]) {
		if (j > PORT_MAXLEN) {
			return (1);
		}
		port2[j] = args[i];
		++i;
		++j;
	}
	port2[j] = '\0';

	return (0);
}

static void	usage(char *prog)
{
	dprintf(2, "usage: %s [options]\n\n"
				"reverse: -r <ip:port>\n"
				"listen: -l <master port>:<slave port>\n"
				"command: -c <command> - When used in conjonction with -l, this will send 'command' to the master upon connection\n"
				"                        syntax is 'CONNECT ip:port'\n"
				"daemonize: -d - run as a daemon process\n"
				"public: -p - to use with -l, will make slave port available externaly\n"
				"keepalive: -k <seconds> - to use with -r, will send a keepalive every n seconds.\n"
				"verbose: -v\n\n"
				"Found a bug ? Please report to aguilbau@student.42.fr\n",
				prog);
}

int			main(int ac, char **av)
{
	char	addr[INET_ADDRSTRLEN + 1];
	char	port[PORT_MAXLEN + 1];
	char	port2[PORT_MAXLEN + 1];
	int		opt;
	char	*cmd;
	int		verbose;
	int		reverse_c;
	int		reverse_l;
	int		daemon;
	int		public;
	int		keepalive;
	int		sockfd;

	keepalive = 0;
	verbose = 0;
	cmd = NULL;
	public = 0;
	reverse_c = 0;
	reverse_l = 0;
	daemon = 0;
	while ((opt = getopt(ac, av, ARGS_FORMAT)) != -1) {
		switch (opt) {
		case 'r':
			reverse_c = 1;
			if (parse_remote_addr(addr, port, optarg)) {
				usage(av[0]);
				return (EXIT_FAILURE);
			}
			break ;
		case 'l':
			reverse_l = 1;
			if (parse_bridge(port, port2, optarg)) {
				usage(av[0]);
				return (EXIT_FAILURE);
			}
			break;
		case 'c':
			cmd = optarg;
			break ;
		case 'v':
			verbose = 1;
			break ;
		case 'd':
			daemon = 1;
			break ;
		case 'p':
			public = 1;
			break ;
		case 'k':
			keepalive = atoi(optarg);
			break ;
		default:
			break ;
		}
	}
	if (!reverse_c && !reverse_l) {
		usage(av[0]);
		return (EXIT_FAILURE);
	}
	if (daemon) {
		if (daemonize(verbose)) {
			return (EXIT_FAILURE);
		}
	}
	/* if (keepalive) { */
	/* 	master_sockfd = -1; */
	/* 	set_keepalive(keepalive); */
	/* } */
	if (reverse_c) {
		launch_reverse(addr, port, verbose);
		return (0);
	}
	launch_bridge(port, port2, cmd, verbose, public);
	return (0);
}
