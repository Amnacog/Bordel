/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   writen.c                                           :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: toni </var/mail/toni>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/05/24 04:00:21 by toni              #+#    #+#             */
/*   Updated: 2014/05/24 04:06:51 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <unistd.h>
#include "tcp.h"

size_t				writen(int fd, char *buffer, size_t buff_len)
{
	size_t			n;
	size_t			w;

	n = 0;
	while (n < buff_len)
	{
		if ((w = write(fd, buffer, WRITE_SIZE)) == -1)
			return (-1);
		n += w;
	}
	return (n);
}
