import { Link } from 'react-router-dom';

const Footer = () => (
  <footer className="relative z-10 border-t border-border/70 bg-background/70 px-6 py-4 backdrop-blur-sm">
    <div className="mx-auto flex max-w-7xl flex-col items-center justify-between gap-3 text-sm text-muted-foreground md:flex-row">
      <div className="flex flex-wrap items-center justify-center gap-4 sm:gap-6">
        <Link
          to="/terms"
          className="transition-colors hover:text-foreground"
        >
          Terms & Conditions
        </Link>
        <Link
          to="/privacy"
          className="transition-colors hover:text-foreground"
        >
          Privacy Policy
        </Link>
      </div>
      <p className="text-xs text-center md:text-right">
        © 2026 CPU Scheduling Visualizer · OS Course Project
      </p>
    </div>
  </footer>
);

export default Footer;
