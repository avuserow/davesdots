# .zshrc
# Current author: David Majnemer
# Original author: Saleem Abdulrasool <compnerd@compnerd.org>
# vim:set nowrap:

case `uname -s` in
	Darwin)
		export LHOSTNAME=`scutil --get LocalHostName`
	;;
	*)
		export LHOSTNAME=${HOST}
	;;
esac

autoload compinit; compinit -d "${HOME}/.zsh/.zcompdump-${LHOSTNAME}"

autoload age
autoload zmv

if [ ${ZSH_VERSION//.} -gt 420 ] ; then
	autoload -U url-quote-magic
	zle -N self-insert url-quote-magic
fi

autoload -U edit-command-line
zle -N edit-command-line

# common shell utils
if [ -d "${HOME}/.commonsh" ] ; then
	for file in "${HOME}"/.commonsh/*(N.x:t) ; do
		. "${HOME}/.commonsh/${file}"
	done
fi

# extras
if [ -d "${HOME}/.zsh" ] ; then
	for file in "${HOME}"/.zsh/*(N.x:t) ; do
		. "${HOME}/.zsh/${file}"
	done
fi
