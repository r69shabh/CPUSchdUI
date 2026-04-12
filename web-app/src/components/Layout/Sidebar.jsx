import { BarChart3, BookOpen, LayoutDashboard, X } from 'lucide-react';
import { NavLink } from 'react-router-dom';
import clsx from 'clsx';
import { AnimatePresence, motion } from 'framer-motion'; // eslint-disable-line no-unused-vars
import { Button } from '@/components/ui/button';

const SidebarContent = ({ onClose }) => {
  const menuItems = [
    {
      path: '/visualizer',
      label: 'Simulator',
      subtitle: 'Run scheduling algorithms',
      icon: LayoutDashboard,
    },
    {
      path: '/comparison',
      label: 'Comparison',
      subtitle: 'Compare performance metrics',
      icon: BarChart3,
    },
    {
      path: '/algorithms',
      label: 'Learn',
      subtitle: 'Explore algorithm concepts',
      icon: BookOpen,
    },
  ];

  return (
    <div className="flex h-full min-h-0 flex-col">
      <nav className="custom-scrollbar min-h-0 flex-1 space-y-1.5 overflow-y-auto p-3">
        {menuItems.map((item) => (
          <NavLink
            key={item.path}
            to={item.path}
            onClick={() => {
              if (window.innerWidth < 768) onClose?.();
            }}
            className={({ isActive }) =>
              clsx(
                'group flex w-full items-start gap-3 rounded-xl border px-3 py-3 transition-all',
                isActive
                  ? 'border-primary/30 bg-primary/10 text-foreground shadow-sm'
                  : 'border-transparent text-muted-foreground hover:border-border/80 hover:bg-muted/40 hover:text-foreground'
              )
            }
          >
            <item.icon className="mt-0.5 h-4 w-4 shrink-0" />
            <div>
              <p className="text-sm font-medium leading-tight">{item.label}</p>
              <p className="text-xs text-muted-foreground/90">{item.subtitle}</p>
            </div>
          </NavLink>
        ))}
      </nav>
    </div>
  );
};

const Sidebar = ({ isOpen, onClose }) => {
  return (
    <>
      <aside className="hidden h-full min-h-0 w-72 shrink-0 border-r border-border/70 bg-card/70 backdrop-blur-sm md:flex md:flex-col">
        <SidebarContent onClose={onClose} />
      </aside>

      <AnimatePresence>
        {isOpen && (
          <>
            <motion.div
              initial={{ opacity: 0 }}
              animate={{ opacity: 1 }}
              exit={{ opacity: 0 }}
              onClick={onClose}
              className="fixed inset-0 z-30 bg-background/75 backdrop-blur-sm md:hidden"
            />

            <motion.aside
              initial={{ x: -280 }}
              animate={{ x: 0 }}
              exit={{ x: -280 }}
              transition={{ type: 'spring', damping: 25, stiffness: 200 }}
              className="fixed bottom-0 left-0 top-0 z-40 w-72 overflow-y-auto border-r border-border/70 bg-card/95 shadow-xl backdrop-blur-md md:hidden"
            >
              <div className="flex items-center justify-between border-b border-border/70 p-4">
                <span className="font-semibold">Navigation</span>
                <Button variant="ghost" size="icon" onClick={onClose}>
                  <X className="h-5 w-5" />
                </Button>
              </div>
              <SidebarContent onClose={onClose} />
            </motion.aside>
          </>
        )}
      </AnimatePresence>
    </>
  );
};

export default Sidebar;
