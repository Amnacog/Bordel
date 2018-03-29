/* ************************************************************************** */
/*                                                                            */
/*                                                        :::      ::::::::   */
/*   stdfuns.c                                          :+:      :+:    :+:   */
/*                                                    +:+ +:+         +:+     */
/*   By: aguilbau <aguilbau@student.42.fr>          +#+  +:+       +#+        */
/*                                                +#+#+#+#+#+   +#+           */
/*   Created: 2014/05/11 18:34:33 by aguilbau          #+#    #+#             */
/*   Updated: 2014/06/24 17:56:58 by root             ###   ########.fr       */
/*                                                                            */
/* ************************************************************************** */

#include <stdlib.h>
#include <unistd.h>

static char				**ft_malloc_strings(char **t, char *s, char delim)
{
	unsigned int		i;
	unsigned int		j;
	unsigned int		char_count;

	j = 0;
	i = 0;
	while (s[i])
	{
		char_count = 0;
		while (s[i] == delim)
			i++;
		if (s[i])
		{
			while (s[i] && s[i] != delim && ++char_count)
				i++;
			if (!(t[j++] = (char *)malloc(char_count + 1)))
			{
				free(t);
				return (NULL);
			}
		}
	}
	return (t);
}

static char				**malloc_table(char *s, char delim)
{
	char				**ret;
	unsigned int		i;
	unsigned int		j;

	j = 0;
	i = 0;
	while (s[i])
	{
		while (s[i] == delim)
			i++;
		if (s[i])
		{
			j++;
			while (s[i] && s[i] != delim)
				i++;
		}
	}
	if (!(ret = (char **)malloc(sizeof(char *) * j + 1)))
		return (NULL);
	ret[j] = NULL;
	return (ft_malloc_strings(ret, s, delim));
}

char					**ft_strsplit(char *s, char delim)
{
	char				**ret;
	unsigned int		i;
	unsigned int		j;
	unsigned int		k;

	if ((ret = malloc_table(s, delim)))
	{
		j = 0;
		i = 0;
		while (s[i])
		{
			while (s[i] == delim)
				i++;
			if (s[i])
			{
				k = 0;
				while (s[i] && s[i] != delim)
					ret[j][k++] = s[i++];
				ret[j++][k] = '\0';
			}
		}
	}
	return (ret);
}

void					free_table(char **t)
{
	int					i;

	i = 0;
	while (t[i])
		free(t[i++]);
	free(t);
}
