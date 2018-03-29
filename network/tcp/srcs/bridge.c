/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   bridge.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/25 15:56:39 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/26 23:46:00 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <sys/select.h>
#include <unistd.h>

#define BUFF_SIZE		1024

int						bridge(int master, int slave)
{
	char				buffer[BUFF_SIZE];
	fd_set				readfds;
	struct timeval		tv;
	int					maxfd;
	int					ret;

	if (master > slave)
		maxfd = master;
	else
		maxfd = slave;
	tv.tv_sec = 0;
	tv.tv_usec = 500000;
	FD_ZERO(&readfds);
	while (1)
	{
		FD_SET(master, &readfds);
		FD_SET(slave, &readfds);
		if (select(maxfd + 1, &readfds, NULL, NULL, &tv) < 0) {
			close(slave);
			return (0);
		}
		if (FD_ISSET(master, &readfds))
		{
			if ((ret = read(master, buffer, BUFF_SIZE - 1)) <= 0)
			{
				close(master);
				close(slave);
				return (-1);
			}
			buffer[ret] = 0;
			write(slave, buffer, ret);
		}
		if (FD_ISSET(slave, &readfds))
		{
			if ((ret = read(slave, buffer, BUFF_SIZE - 1)) <= 0)
			{
				close(slave);
				return (0);
			}
			buffer[ret] = 0;
			write(master, buffer, ret);
		}
	}
}
