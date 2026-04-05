import { useState } from 'react';
import { useNavigate } from 'react-router';
import { SearchBar } from '../components/search-bar';
import { CategoryChip } from '../components/category-chip';
import { OfferCard } from '../components/offer-card';
import { MerchantCard } from '../components/merchant-card';
import { mockOffers, mockMerchants, categories } from '../data/mockData';
import { ArrowRight } from 'lucide-react';

export function Explorer() {
  const navigate = useNavigate();
  const [selectedCategory, setSelectedCategory] = useState('all');
  const [searchQuery, setSearchQuery] = useState('');

  const filteredOffers = mockOffers.filter(offer => {
    const matchesCategory = selectedCategory === 'all' || 
      offer.category.toLowerCase() === selectedCategory;
    const matchesSearch = offer.title.toLowerCase().includes(searchQuery.toLowerCase()) ||
      offer.subtitle.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  const filteredMerchants = mockMerchants.filter(merchant => {
    const matchesCategory = selectedCategory === 'all' || 
      merchant.category.toLowerCase() === selectedCategory;
    const matchesSearch = merchant.name.toLowerCase().includes(searchQuery.toLowerCase());
    return matchesCategory && matchesSearch;
  });

  return (
    <div className="pb-20 bg-gray-50 min-h-screen">
      {/* Header */}
      <div className="bg-white px-5 pt-12 pb-4 sticky top-0 z-10 shadow-sm">
        <h1 className="text-2xl font-bold mb-4">Explorer</h1>
        
        {/* Search */}
        <SearchBar
          placeholder="Rechercher une offre ou un commerce..."
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
        {/* Offres Section */}
        <div className="mb-8">
          <h2 className="text-lg font-bold mb-4">
            Résultats près de toi ({filteredOffers.length} offres)
          </h2>
          <div className="flex gap-4 overflow-x-auto pb-2 -mx-5 px-5 scrollbar-hide">
            {filteredOffers.map((offer) => (
              <OfferCard key={offer.id} offer={offer} />
            ))}
          </div>
        </div>

        {/* Merchants Section */}
        <div>
          <div className="flex items-center justify-between mb-4">
            <h2 className="text-lg font-bold">Commerces populaires autour de toi</h2>
            <button
              onClick={() => navigate('/merchants')}
              className="text-sm text-red-600 font-medium flex items-center gap-1 hover:gap-2 transition-all"
            >
              Voir tout
              <ArrowRight className="w-4 h-4" />
            </button>
          </div>
          
          <div className="flex flex-col gap-3">
            {filteredMerchants.slice(0, 5).map((merchant) => (
              <MerchantCard key={merchant.id} merchant={merchant} />
            ))}
          </div>
        </div>
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
