interface CategoryChipProps {
  icon: string;
  label: string;
  active?: boolean;
  onClick?: () => void;
}

export function CategoryChip({ icon, label, active = false, onClick }: CategoryChipProps) {
  return (
    <button
      onClick={onClick}
      className={`
        flex-shrink-0 px-4 py-2 rounded-full text-sm font-medium transition-all
        ${active 
          ? 'bg-red-600 text-white shadow-sm' 
          : 'bg-gray-100 text-gray-700 hover:bg-gray-200'
        }
      `}
    >
      <span className="flex items-center gap-1.5">
        <span>{icon}</span>
        <span>{label}</span>
      </span>
    </button>
  );
}
