import { Cpu, Github, Moon, Sun } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import { useTheme } from '../../hooks/useTheme';
import { Button } from '@/components/ui/button';
import { Badge } from '@/components/ui/badge';
import clsx from 'clsx';

const Header = () => {
  const { isDarkMode, toggleTheme } = useTheme();
  const navItems = [
    { path: '/visualizer', label: 'Simulator' },
    { path: '/comparison', label: 'Comparison' },
    { path: '/algorithms', label: 'Learn' },
  ];

  return (
    <header className="app-header sticky top-0 z-50 border-b border-border/70 bg-background/85 backdrop-blur-md">
      <div className="flex w-full items-center justify-between px-4 py-3 md:px-6 lg:px-8">
        <div className="min-w-0 flex items-center gap-3">
          <div className="flex h-10 w-10 items-center justify-center rounded-full bg-gradient-to-br from-blue-500 to-cyan-400 text-white shadow-md shadow-blue-500/25 overflow-hidden">
            <img
              src="/favicon.png"
              alt="Logo"
              className="h-full w-full object-cover"
            />
          </div>
          <div className="hidden min-w-0 leading-tight sm:block">
            <h1 className="truncate text-sm font-semibold tracking-tight">
              CPU Scheduler
            </h1>
            <p className="text-xs text-muted-foreground">Scheduling Visualizer</p>
          </div>
          <Badge variant="outline" className="hidden border-border/80 bg-card/60 md:inline-flex">
            v1.0
          </Badge>
        </div>

        <nav className="hidden items-center gap-1 rounded-full border border-border/80 bg-card/60 p-1 md:flex">
          {navItems.map((item) => (
            <NavLink
              key={item.path}
              to={item.path}
              className={({ isActive }) =>
                clsx(
                  'rounded-full px-3 py-1.5 text-xs font-medium transition-colors',
                  isActive
                    ? 'bg-primary/20 text-foreground'
                    : 'text-muted-foreground hover:text-foreground'
                )
              }
            >
              {item.label}
            </NavLink>
          ))}
        </nav>

        <div className="flex items-center gap-1">
          <Button
            variant="ghost"
            size="icon"
            onClick={toggleTheme}
            title={isDarkMode ? 'Switch to Light Mode' : 'Switch to Dark Mode'}
            className="text-muted-foreground hover:text-foreground"
          >
            {isDarkMode ? (
              <Sun className="h-4 w-4" />
            ) : (
              <Moon className="h-4 w-4" />
            )}
          </Button>
          <Button variant="ghost" size="icon" asChild>
            <a
              href="https://github.com/Yash121l/sem6-os-project"
              target="_blank"
              rel="noopener noreferrer"
            >
              <Github className="h-4 w-4" />
            </a>
          </Button>
        </div>
      </div>
    </header>
  );
};

export default Header;
