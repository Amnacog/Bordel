/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tcp.h                                              :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/05/11 18:45:52 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/27 13:01:22 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef TCP_H
# define TCP_H

# include <stddef.h>
# include <sys/time.h>
# include <netinet/in.h>

# define WRITE_SIZE			1024

# define PORT_MAXLEN		5

int						tcp_connect(char *addr, char *port, struct timeval *timeout, int verbose);
int						tcp_listen(char *port, int backlog, int verbose, int flag);
size_t					writen(int fd, char *buffer, size_t buff_len);

#endif
