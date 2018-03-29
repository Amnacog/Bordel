/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   keepalive.c                                        :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: toni </var/mail/toni>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/29 15:19:11 by toni              #+#    #+#             */
/*   Updated: 2014/06/29 15:32:11 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include "tcproxy.h"
#include <unistd.h>
#include <sys/time.h>
#include <signal.h>

void				sighandler(int n)
{
	static int		interval;

	if (!interval) {
		signal(SIGALRM, sighandler);
		interval = n;
	} else {
		if (master_sockfd != -1) {
			write(master_sockfd, "42", 2);
		}
	}
	alarm(interval);
}

void				set_keepalive(int seconds)
{
	sighandler(seconds);
}
