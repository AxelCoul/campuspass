import { useState } from 'react';
import { useNavigate } from 'react-router';
import { SearchBar } from '../components/search-bar';
import { CategoryChip } from '../components/category-chip';
import { MerchantCard } from '../components/merchant-card';
import { mockMerchants, categories } from '../data/mockData';
import { ArrowLeft } from 'lucide-react';

export function Merchants() {
  const navigate = useNavigate();
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const filteredMerchants = mockMerchants.filter(merchant => {
    const matchesCategory = selectedCategory === 'all' || 
      merchant.category.toLowerCase() === selectedCategory;
    const matchesSearch = merchant.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const popularMerchants = filteredMerchants.filter(m => m.distance < 1);
  const nearbyMerchants = filteredMerchants.filter(m => m.distance >= 1 && m.distance < 2);

  return (
    <div className="pb-20 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-white px-5 pt-12 pb-4 sticky top-0 z-10 shadow-sm">
        <div className="flex items-center gap-3 mb-4">
          <button
            onClick={() => navigate(-1)}
            className="w-9 h-9 flex items-center justify-center rounded-full hover:bg-gray-100 transition-colors"
          >
            <ArrowLeft className="w-5 h-5" />
          </button>
          <div>
            <h1 className="text-2xl font-bold">Commerces autour de toi</h1>
            <p className="text-sm text-gray-500 mt-0.5">
              Découvre les lieux où utiliser ton PASS CAMPUS
            </p>
          </div>
        </div>
        
        {/* Search */}
        <SearchBar
          placeholder="Rechercher un commerce..."
          value={searchQuery}
          onChange={setSearchQuery}
        />

        {/* Categories */}
        <div className="flex gap-2 overflow-x-auto pb-2 mt-4 -mx-5 px-5 scrollbar-hide">
          {categories.map((category) => (
            <CategoryChip
              key={category.id}
              icon={category.icon}
              label={category.label}
              active={selectedCategory === category.id}
              onClick={() => setSelectedCategory(category.id)}
            />
          ))}
        </div>
      </div>

      {/* Content */}
      <div className="px-5 py-6">
        {/* Commerces populaires */}
        {popularMerchants.length > 0 && (
          <div className="mb-8">
            <h2 className="text-lg font-bold mb-4">Commerces populaires</h2>
            <div className="flex flex-col gap-3">
              {popularMerchants.map((merchant) => (
                <MerchantCard key={merchant.id} merchant={merchant} />
              ))}
            </div>
          </div>
        )}

        {/* À proximité */}
        {nearbyMerchants.length > 0 && (
          <div>
            <h2 className="text-lg font-bold mb-4">À proximité (moins de 2 km)</h2>
            <div className="flex flex-col gap-3">
              {nearbyMerchants.map((merchant) => (
                <MerchantCard key={merchant.id} merchant={merchant} />
              ))}
            </div>
          </div>
        )}

        {/* Empty state */}
        {filteredMerchants.length === 0 && (
          <div className="text-center py-12">
            <p className="text-gray-500">Aucun commerce trouvé</p>
          </div>
        )}
      </div>

      <style>{`
        .scrollbar-hide::-webkit-scrollbar {
          display: none;
        }
        .scrollbar-hide {
          -ms-overflow-style: none;
          scrollbar-width: none;
        }
      `}</style>
    </div>
  );
}
