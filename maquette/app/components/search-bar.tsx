import { Search } from 'lucide-react';

interface SearchBarProps {
  placeholder?: string;
  value?: string;
  onChange?: (value: string) => void;
}

export function SearchBar({ 
  placeholder = 'Rechercher...', 
  value = '',
  onChange 
}: SearchBarProps) {
  return (
    <div className="relative w-full">
      <Search className="absolute left-3 top-1/2 -translate-y-1/2 w-5 h-5 text-gray-400" />
      <input
        type="text"
        placeholder={placeholder}
        value={value}
        onChange={(e) => onChange?.(e.target.value)}
        className="w-full h-11 pl-11 pr-4 bg-gray-100 rounded-full text-sm placeholder:text-gray-500 focus:outline-none focus:ring-2 focus:ring-red-600/20 focus:bg-white transition-all"
      />
    </div>
  );
}
