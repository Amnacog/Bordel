/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   tcproxy.h                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: toni </var/mail/toni>                      +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/06/24 06:05:15 by toni              #+#    #+#             */
/*   Updated: 2014/06/29 15:21:43 by toni             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#ifndef TCPROXY_H
# define TCPROXY_H

#include <sys/select.h>

# define STRLEN(s)	(sizeof(s) - 1)

# define ERROR_500	"500 Internal Server Error"

int					master_sockfd;

int					launch_reverse(char *addr, char *port, int verbose);
int					reverse_tcp(int sockfd);
int					parse_remote_addr(char *addr, char *port, char *args);
int					process_request(int sockfd, int verbose);
int					bridge(int master, int slave);
int					ft_select(fd_set *rfd, int fds[], int verbose);
int					launch_bridge(char *port1, char *port2, char *cmd, int verbose, int public);
int					daemonize(int verbose);
void				set_keepalive(int seconds);

#endif /* !TCPROXY_H */
