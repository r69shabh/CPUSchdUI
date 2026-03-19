import { render, screen } from '@testing-library/react';
import { describe, it, expect } from 'vitest';
import ProcessInput from '../ProcessInput';

describe('ProcessInput', () => {
  it('renders correctly', () => {
    render(<ProcessInput />);
    expect(screen.getByText('Processes')).toBeInTheDocument();
  });
});
