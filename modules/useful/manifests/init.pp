class useful{
  package { "vim":
      ensure => "installed"
    }
  package { "tmux":
      ensure => "installed"
    }
}
