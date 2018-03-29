#******************************************************************************#
#                                                                              #
#                                                         :::      ::::::::    #
#    Makefile                                           :+:      :+:    :+:    #
#                                                     +:+ +:+         +:+      #
#    By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+         #
#                                                 +#+#+#+#+#+   +#+            #
#    Created: 2014/05/06 16:58:00 by aguilbau          #+#    #+#              #
#    Updated: 2014/06/29 15:21:57 by toni             ###   ########.fr        #
#                                                                              #
#******************************************************************************#

NAME	=	tcproxy

SRC		=	main.c \
			tcp_connect.c \
			tcp_listen.c \
			writen.c \
			launch_reverse.c \
			process_request.c \
			parse_remote_addr.c \
			bridge.c \
			stdfuns.c \
			launch_bridge.c \
			daemonize.c \
			keepalive.c

OBJ		=	$(addprefix objs/,$(SRC:.c=.o))

VPATH	=	srcs/

CC		=	gcc

CFLAGS	=	-I./includes

all : $(NAME)

$(NAME) : $(OBJ)
		$(CC) $(OBJ) -o $(NAME)

objs/%.o: srcs/%.c
	mkdir -p $(dir $@)
	gcc -o $@ -c $< $(CFLAGS)

eclean :
		/bin/rm -f *~ srcs/*~ includes/*~

clean : eclean
		/bin/rm -rf objs	

fclean : clean
		/bin/rm -f $(NAME)

re : fclean all
