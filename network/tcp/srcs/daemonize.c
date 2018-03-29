/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   daemonize.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: toni </var/mail/toni>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/26 22:19:06 by toni              #+#    #+#             */
/*   Updated: 2014/06/26 23:11:56 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>
#include <signal.h>

int				daemonize(int verbose)
{
	int			pid;

	if ((pid = fork()) < 0) {
		if (verbose) {
			perror("fork()");
			return (1);
		}
	}

	if (pid == 0) {
		signal(SIGCHLD, SIG_IGN);
		signal(SIGHUP, SIG_IGN);
		if (setsid() < 0) {
			if (verbose) {
				perror("setsid()");
			}
			return (1);
		}

		if (chdir("/tmp/") < 0) {
			if (verbose) {
				perror("chdir()");
				return (1);
			}
		}

		/* This piece of code will terminate the programm, no idea why */

		/* umask(0); */
		/* close(STDIN_FILENO); */
		/* close(STDOUT_FILENO); */
		/* close(STDERR_FILENO); */
		return (0);
	}

	exit(0);
}
