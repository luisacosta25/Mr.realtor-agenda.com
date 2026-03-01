```html
<!DOCTYPE html>
<html lang="es">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Mr.Realtor/Agenda.com - Luis Acosta</title>
    <script src="https://cdn.tailwindcss.com"></script>
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        @import url('https://fonts.googleapis.com/css2?family=Inter:wght@300;400;500;600;700&display=swap');
        
        body {
            font-family: 'Inter', sans-serif;
            background-color: #f3f4f6;
        }

        .sidebar-link.active {
            background-color: #1e3a8a;
            border-right: 4px solid #60a5fa;
        }

        /* Custom Scrollbar */
        ::-webkit-scrollbar {
            width: 8px;
        }
        ::-webkit-scrollbar-track {
            background: #f1f1f1; 
        }
        ::-webkit-scrollbar-thumb {
            background: #cbd5e1; 
            border-radius: 4px;
        }
        ::-webkit-scrollbar-thumb:hover {
            background: #94a3b8; 
        }

        .property-card {
            transition: all 0.3s ease;
        }
        .property-card:hover {
            transform: translateY(-2px);
            box-shadow: 0 10px 15px -3px rgba(0, 0, 0, 0.1), 0 4px 6px -2px rgba(0, 0, 0, 0.05);
        }

        .status-badge {
            font-size: 0.75rem;
            padding: 0.25rem 0.75rem;
            border-radius: 9999px;
            font-weight: 600;
        }

        /* Calendar Styles */
        .calendar-grid {
            display: grid;
            grid-template-columns: repeat(7, 1fr);
            gap: 1px;
            background-color: #e2e8f0;
            border: 1px solid #e2e8f0;
        }
        .calendar-day {
            background-color: white;
            min-height: 100px;
            padding: 0.5rem;
        }
    </style>
</head>
<body class="text-gray-800 h-screen overflow-hidden flex flex-col">

    <!-- LOGIN SCREEN -->
    <div id="loginScreen" class="fixed inset-0 z-50 bg-white flex items-center justify-center">
        <div class="absolute inset-0 bg-cover bg-center opacity-20" style="background-image: url('https://images.unsplash.com/photo-1560518883-ce09059eeffa?w=1920');"></div>
        <div class="bg-white p-8 rounded-2xl shadow-2xl w-full max-w-md relative z-10 border border-gray-100">
            <div class="text-center mb-8">
                <h1 class="text-3xl font-bold text-blue-900 mb-2">Mr.Realtor/Agenda.com</h1>
                <p class="text-gray-500">Acceso Exclusivo para Agentes</p>
            </div>
            
            <form id="loginForm" class="space-y-6">
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Número de Celular</label>
                    <input type="text" id="loginPhone" placeholder="Ingrese su número" class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition" required>
                </div>
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Código de Seguridad</label>
                    <input type="password" id="loginCode" placeholder="Ingrese su código" class="w-full px-4 py-3 rounded-lg border border-gray-300 focus:ring-2 focus:ring-blue-500 focus:border-blue-500 outline-none transition" required>
                </div>
                <button type="submit" class="w-full bg-blue-900 hover:bg-blue-800 text-white font-bold py-3 rounded-lg transition duration-300 shadow-lg transform hover:scale-[1.02]">
                    INGRESAR
                </button>
                <div id="loginError" class="text-red-500 text-center text-sm hidden">Credenciales incorrectas.</div>
            </form>
            <div class="mt-6 text-center">
                <p class="text-xs text-gray-400">Mamba Realty LLC - Luis Acosta</p>
            </div>
        </div>
    </div>

    <!-- MAIN APP (Hidden by default) -->
    <div id="appContainer" class="hidden flex h-full">
        
        <!-- SIDEBAR -->
        <aside class="w-64 bg-blue-900 text-white flex flex-col shadow-xl">
            <div class="p-6 border-b border-blue-800">
                <h2 class="text-xl font-bold tracking-wide">Mr.Realtor</h2>
                <p class="text-xs text-blue-300 mt-1">Agenda Pro</p>
            </div>
            
            <nav class="flex-1 py-6 space-y-1">
                <a href="#" onclick="showSection('properties')" id="nav-properties" class="sidebar-link active flex items-center px-6 py-3 text-blue-100 hover:bg-blue-800 transition">
                    <i class="fas fa-home w-6"></i>
                    <span>Propiedades</span>
                </a>
                <a href="#" onclick="showSection('calendar')" id="nav-calendar" class="sidebar-link flex items-center px-6 py-3 text-blue-100 hover:bg-blue-800 transition">
                    <i class="fas fa-calendar-alt w-6"></i>
                    <span>Calendario</span>
                </a>
                <a href="#" onclick="showSection('templates')" id="nav-templates" class="sidebar-link flex items-center px-6 py-3 text-blue-100 hover:bg-blue-800 transition">
                    <i class="fas fa-comment-dots w-6"></i>
                    <span>Plantillas SMS</span>
                </a>
            </nav>

            <div class="p-4 border-t border-blue-800">
                <div class="flex items-center gap-3">
                    <div class="w-10 h-10 rounded-full bg-blue-700 flex items-center justify-center font-bold">LA</div>
                    <div>
                        <p class="text-sm font-medium">Luis Acosta</p>
                        <p class="text-xs text-blue-300">Broker - Mamba Realty</p>
                    </div>
                </div>
                <button onclick="logout()" class="mt-4 w-full text-xs text-red-300 hover:text-red-100 flex items-center justify-center gap-2">
                    <i class="fas fa-sign-out-alt"></i> Cerrar Sesión
                </button>
            </div>
        </aside>

        <!-- MAIN CONTENT -->
        <main class="flex-1 overflow-y-auto bg-gray-50 relative">
            <!-- Header -->
            <header class="bg-white shadow-sm sticky top-0 z-20 px-8 py-4 flex justify-between items-center">
                <h2 id="pageTitle" class="text-2xl font-bold text-gray-800">Gestión de Propiedades</h2>
                <div class="flex items-center gap-4">
                    <button onclick="openPropertyModal()" class="bg-green-600 hover:bg-green-700 text-white px-5 py-2 rounded-lg shadow transition flex items-center gap-2">
                        <i class="fas fa-plus"></i> Nueva Propiedad
                    </button>
                </div>
            </header>

            <!-- PROPERTIES SECTION -->
            <div id="section-properties" class="p-8">
                <!-- Filters -->
                <div class="mb-6 flex flex-wrap gap-2">
                    <button onclick="filterProperties('all')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-blue-900 text-white shadow-sm">Todos</button>
                    <button onclick="filterProperties('Lead Activo')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Lead Activo</button>
                    <button onclick="filterProperties('Llamar 2da vez')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Llamar 2da</button>
                    <button onclick="filterProperties('Llamar 3ra vez')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Llamar 3ra</button>
                    <button onclick="filterProperties('Llamar 4ta vez')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Llamar 4ta</button>
                    <button onclick="filterProperties('Pendiente')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Pendiente</button>
                    <button onclick="filterProperties('Bajo Contrato')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Bajo Contrato</button>
                    <button onclick="filterProperties('Listing')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Listing</button>
                    <button onclick="filterProperties('Vendida')" class="filter-btn px-4 py-1.5 rounded-full text-sm font-medium bg-white text-gray-600 border hover:bg-gray-50">Vendida</button>
                </div>

                <!-- Grid -->
                <div id="propertiesGrid" class="grid grid-cols-1 md:grid-cols-2 xl:grid-cols-3 gap-6">
                    <!-- Properties will be injected here via JS -->
                </div>
            </div>

            <!-- CALENDAR SECTION -->
            <div id="section-calendar" class="p-8 hidden">
                <div class="bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden">
                    <div class="p-4 border-b border-gray-200 flex justify-between items-center bg-gray-50">
                        <h3 class="font-bold text-lg" id="currentMonthYear">Octubre 2023</h3>
                        <div class="flex gap-2">
                            <button onclick="changeMonth(-1)" class="p-2 hover:bg-gray-200 rounded"><i class="fas fa-chevron-left"></i></button>
                            <button onclick="changeMonth(1)" class="p-2 hover:bg-gray-200 rounded"><i class="fas fa-chevron-right"></i></button>
                        </div>
                    </div>
                    <div class="grid grid-cols-7 bg-gray-200 gap-px">
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Dom</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Lun</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Mar</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Mié</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Jue</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Vie</div>
                        <div class="bg-gray-50 p-2 text-center text-sm font-bold text-gray-500">Sáb</div>
                    </div>
                    <div id="calendarDays" class="calendar-grid">
                        <!-- Days injected via JS -->
                    </div>
                </div>
            </div>

            <!-- TEMPLATES SECTION -->
            <div id="section-templates" class="p-8 hidden">
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <!-- English Templates -->
                    <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                        <h3 class="font-bold text-lg mb-4 text-blue-900 border-b pb-2">English Templates</h3>
                        <div class="space-y-4">
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Greetings')">
                                <h4 class="font-semibold text-sm">Greetings</h4>
                                <p class="text-xs text-gray-600 mt-1">"Hello! This is Luis Acosta from Mamba Realty LLC. Just checking in regarding your property interest..."</p>
                            </div>
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Contract Info')">
                                <h4 class="font-semibold text-sm">Contract Info</h4>
                                <p class="text-xs text-gray-600 mt-1">"Hi, sending over the contract details for your review. Please let me know if you have questions. - Luis Acosta, Mamba Realty"</p>
                            </div>
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Congratulations')">
                                <h4 class="font-semibold text-sm">Congratulations</h4>
                                <p class="text-xs text-gray-600 mt-1">"Congratulations on the successful sale! It was a pleasure working with you. - Luis Acosta"</p>
                            </div>
                        </div>
                    </div>

                    <!-- Spanish Templates -->
                    <div class="bg-white p-6 rounded-xl shadow-sm border border-gray-200">
                        <h3 class="font-bold text-lg mb-4 text-blue-900 border-b pb-2">Plantillas en Español</h3>
                        <div class="space-y-4">
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Saludos')">
                                <h4 class="font-semibold text-sm">Saludos</h4>
                                <p class="text-xs text-gray-600 mt-1">"¡Hola! Soy Luis Acosta de Mamba Realty LLC. Le escribo para dar seguimiento a su interés en la propiedad..."</p>
                            </div>
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Info Contrato')">
                                <h4 class="font-semibold text-sm">Info Contrato</h4>
                                <p class="text-xs text-gray-600 mt-1">"Hola, le envío los detalles del contrato para su revisión. Quedo atento. - Luis Acosta, Mamba Realty"</p>
                            </div>
                            <div class="p-3 bg-gray-50 rounded border hover:bg-blue-50 cursor-pointer transition" onclick="copyTemplate('Felicitaciones')">
                                <h4 class="font-semibold text-sm">Felicitaciones</h4>
                                <p class="text-xs text-gray-600 mt-1">"¡Felicitaciones por haber cerrado el trato y obtener una venta exitosa! Fue un placer trabajar con usted. - Luis Acosta"</p>
                            </div>
                        </div>
                    </div>
                </div>
            </div>

        </main>
    </div>

    <!-- MODAL: ADD/EDIT PROPERTY -->
    <div id="propertyModal" class="fixed inset-0 z-50 bg-black bg-opacity-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-4xl max-h-[90vh] overflow-y-auto m-4">
            <div class="p-6 border-b flex justify-between items-center sticky top-0 bg-white z-10">
                <h3 class="text-xl font-bold text-gray-800" id="modalTitle">Nueva Propiedad</h3>
                <button onclick="closePropertyModal()" class="text-gray-400 hover:text-gray-600"><i class="fas fa-times text-xl"></i></button>
            </div>
            
            <form id="propertyForm" class="p-6 space-y-6">
                <input type="hidden" id="propId">
                
                <!-- Basic Info -->
                <div class="grid grid-cols-1 md:grid-cols-2 gap-6">
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1">URL de la Propiedad (Zillow/Realtor)</label>
                        <input type="text" id="propUrl" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none" placeholder="https://...">
                    </div>
                    
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Nombre del Dueño</label>
                        <input type="text" id="propOwner" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none" required>
                    </div>
                    <div>
                        <label class="block text-sm font-medium text-gray-700 mb-1">Teléfono</label>
                        <input type="text" id="propPhone" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none" placeholder="(239)..." required>
                    </div>
                    <div class="md:col-span-2">
                        <label class="block text-sm font-medium text-gray-700 mb-1">Email</label>
                        <input type="email" id="propEmail" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none">
                    </div>
                </div>

                <!-- Property Details -->
                <div class="bg-gray-50 p-4 rounded-lg border border-gray-200">
                    <h4 class="font-semibold text-gray-700 mb-3 border-b pb-2">Detalles de la Propiedad</h4>
                    <div class="grid grid-cols-2 md:grid-cols-4 gap-4">
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Cuartos (Beds)</label>
                            <input type="number" id="propBeds" class="w-full px-2 py-1.5 border rounded text-sm">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Baños (Baths)</label>
                            <input type="number" id="propBaths" class="w-full px-2 py-1.5 border rounded text-sm">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Sq Ft</label>
                            <input type="number" id="propSqft" class="w-full px-2 py-1.5 border rounded text-sm">
                        </div>
                        <div>
                            <label class="block text-xs font-medium text-gray-500 mb-1">Comisión (%)</label>
                            <input type="number" step="0.1" id="propCommission" class="w-full px-2 py-1.5 border rounded text-sm">
                        </div>
                    </div>
                    <div class="grid grid-cols-2 gap-4 mt-4">
                        <div class="flex items-center gap-2">
                            <input type="checkbox" id="propFlood" class="w-4 h-4 text-blue-600 rounded">
                            <label class="text-sm text-gray-700">Zona de Inundación</label>
                        </div>
                        <div class="flex items-center gap-2">
                            <input type="checkbox" id="propWetland" class="w-4 h-4 text-blue-600 rounded">
                            <label class="text-sm text-gray-700">Zona Wetland</label>
                        </div>
                    </div>
                </div>

                <!-- Status -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">Estado / Categoría</label>
                    <select id="propStatus" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none bg-white">
                        <option value="Lead Activo">Lead Activo</option>
                        <option value="Llamar 2da vez">Llamar por segunda vez</option>
                        <option value="Llamar 3ra vez">Llamar por tercera vez</option>
                        <option value="Llamar 4ta vez">Llamar por cuarta vez</option>
                        <option value="Pendiente">Pendiente</option>
                        <option value="Bajo Contrato">Bajo Contrato</option>
                        <option value="Listing">Listing (Agente Listador)</option>
                        <option value="Vendida">Vendida</option>
                        <option value="En Progreso">En Progreso</option>
                        <option value="Finalizado">Finalizado</option>
                    </select>
                </div>

                <!-- Image Placeholder -->
                <div>
                    <label class="block text-sm font-medium text-gray-700 mb-1">URL de Imagen Principal</label>
                    <input type="text" id="propImage" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none" placeholder="https://... (Opcional)">
                    <p class="text-xs text-gray-500 mt-1">Si se deja vacío, se usará una imagen genérica.</p>
                </div>

                <div class="flex justify-end gap-3 pt-4 border-t">
                    <button type="button" onclick="closePropertyModal()" class="px-4 py-2 border rounded-lg hover:bg-gray-50 text-gray-700">Cancelar</button>
                    <button type="submit" class="px-6 py-2 bg-blue-900 text-white rounded-lg hover:bg-blue-800 shadow-lg">Guardar Propiedad</button>
                </div>
            </form>
        </div>
    </div>

    <!-- MODAL: SEND MESSAGE -->
    <div id="messageModal" class="fixed inset-0 z-50 bg-black bg-opacity-50 hidden flex items-center justify-center backdrop-blur-sm">
        <div class="bg-white rounded-xl shadow-2xl w-full max-w-md p-6">
            <h3 class="text-lg font-bold mb-4">Enviar Mensaje de Texto</h3>
            <p class="text-sm text-gray-600 mb-4">Enviando desde: <span class="font-bold text-blue-900">(239)286-4485</span></p>
            
            <div class="mb-4">
                <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Para</label>
                <input type="text" id="msgTo" class="w-full px-3 py-2 bg-gray-100 border rounded-lg" readonly>
            </div>
            
            <div class="mb-4">
                <label class="block text-xs font-bold text-gray-500 uppercase mb-1">Mensaje</label>
                <textarea id="msgBody" rows="4" class="w-full px-3 py-2 border rounded-lg focus:ring-2 focus:ring-blue-500 outline-none"></textarea>
            </div>

            <div class="flex justify-end gap-3">
                <button onclick="closeMessageModal()" class="px-4 py-2 text-gray-600 hover:bg-gray-100 rounded">Cancelar</button>
                <button onclick="sendMessage()" class="px-6 py-2 bg-green-600 text-white rounded-lg hover:bg-green-700 shadow flex items-center gap-2">
                    <i class="fas fa-paper-plane"></i> Enviar
                </button>
            </div>
        </div>
    </div>

    <!-- TOAST NOTIFICATION -->
    <div id="toast" class="fixed bottom-5 right-5 bg-gray-800 text-white px-6 py-3 rounded-lg shadow-lg transform translate-y-20 opacity-0 transition-all duration-300 z-50 flex items-center gap-3">
        <i class="fas fa-check-circle text-green-400"></i>
        <span id="toastMsg">Acción completada</span>
    </div>

    <script>
        // --- DATA & STATE ---
        const USER_PHONE = "2392864485";
        const SECURITY_CODE = "050407";
        
        let properties = JSON.parse(localStorage.getItem('mamba_properties')) || [];
        let currentFilter = 'all';
        let currentDate = new Date();

        // Sample data for demo
        if (properties.length === 0) {
            properties = [
                {
                    id: 1,
                    url: 'https://zillow.com/example1',
                    owner: 'Juan Pérez',
                    phone: '(239)555-1234',
                    email: 'juan@email.com',
                    beds: 3,
                    baths: 2,
                    sqft: 1800,
                    commission: 3.5,
                    flood: false,
                    wetland: false,
                    status: 'Lead Activo',
                    image: ''
                },
                {
                    id: 2,
                    url: 'https://realtor.com/example2',
                    owner: 'Maria Rodriguez',
                    phone: '(239)555-5678',
                    email: 'maria@email.com',
                    beds: 4,
                    baths: 3,
                    sqft: 2500,
                    commission: 4.0,
                    flood: true,
                    wetland: false,
                    status: 'Bajo Contrato',
                    image: ''
                },
                {
                    id: 3,
                    url: 'https://zillow.com/example3',
                    owner: 'Carlos Mendez',
                    phone: '(239)555-9012',
                    email: 'carlos@email.com',
                    beds: 2,
                    baths: 1,
                    sqft: 1200,
                    commission: 3.0,
                    flood: false,
                    wetland: true,
                    status: 'Pendiente',
                    image: ''
                }
            ];
            localStorage.setItem('mamba_properties', JSON.stringify(properties));
        }

        // --- AUTH ---
        document.getElementById('loginForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const phone = document.getElementById('loginPhone').value.trim().replace(/\D/g, '');
            const code = document.getElementById('loginCode').value.trim();

            if (phone === USER_PHONE && code === SECURITY_CODE) {
                document.getElementById('loginScreen').classList.add('hidden');
                document.getElementById('appContainer').classList.remove('hidden');
                renderProperties();
                renderCalendar();
            } else {
                document.getElementById('loginError').classList.remove('hidden');
            }
        });

        function logout() {
            location.reload();
        }

        // --- NAVIGATION ---
        function showSection(sectionId) {
            // Hide all sections
            ['properties', 'calendar', 'templates'].forEach(id => {
                document.getElementById(`section-${id}`).classList.add('hidden');
                document.getElementById(`nav-${id}`).classList.remove('active', 'bg-blue-800', 'border-r-4', 'border-blue-400');
            });

            // Show target
            document.getElementById(`section-${sectionId}`).classList.remove('hidden');
            const navLink = document.getElementById(`nav-${sectionId}`);
            navLink.classList.add('active');
            
            // Update Title
            const titles = {
                'properties': 'Gestión de Propiedades',
                'calendar': 'Calendario de Citas',
                'templates': 'Plantillas de Mensajes'
            };
            document.getElementById('pageTitle').innerText = titles[sectionId];
        }

        // --- PROPERTIES LOGIC ---
        function renderProperties() {
            const grid = document.getElementById('propertiesGrid');
            grid.innerHTML = '';

            const filtered = currentFilter === 'all' 
                ? properties 
                : properties.filter(p => p.status === currentFilter);

            if (filtered.length === 0) {
                grid.innerHTML = `<div class="col-span-full text-center py-12 text-gray-400">
                    <i class="fas fa-folder-open text-4xl mb-3"></i>
                    <p>No hay propiedades en esta categoría.</p>
                </div>`;
                return;
            }

            filtered.forEach(prop => {
                const img = prop.image || 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=400';
                const statusColor = getStatusColor(prop.status);
                
                const card = document.createElement('div');
                card.className = 'property-card bg-white rounded-xl shadow-sm border border-gray-200 overflow-hidden flex flex-col';
                card.innerHTML = `
                    <div class="relative h-48 bg-gray-200">
                        <img src="${img}" class="w-full h-full object-cover">
                        <span class="absolute top-3 right-3 status-badge ${statusColor} text-white shadow-sm">${prop.status}</span>
                        <div class="absolute bottom-0 left-0 right-0 bg-gradient-to-t from-black/70 to-transparent p-3">
                            <h3 class="text-white font-bold text-lg truncate">${prop.owner || 'Propiedad Sin Nombre'}</h3>
                        </div>
                    </div>
                    <div class="p-4 flex-1 flex flex-col">
                        <div class="flex justify-between items-start mb-3">
                            <div class="flex gap-3 text-sm text-gray-600">
                                <span><i class="fas fa-bed text-blue-500"></i> ${prop.beds || '-'}</span>
                                <span><i class="fas fa-bath text-blue-500"></i> ${prop.baths || '-'}</span>
                                <span><i class="fas fa-ruler-combined text-blue-500"></i> ${prop.sqft || '-'}</span>
                            </div>
                            ${prop.commission ? `<span class="text-xs font-bold text-green-600 bg-green-50 px-2 py-1 rounded">Comm: ${prop.commission}%</span>` : ''}
                        </div>
                        
                        <div class="space-y-2 mb-4 flex-1">
                            <div class="flex items-center gap-2 text-sm text-gray-700">
                                <i class="fas fa-user text-gray-400 w-5"></i> ${prop.owner}
                            </div>
                            <div class="flex items-center gap-2 text-sm text-gray-700">
                                <i class="fas fa-phone text-gray-400 w-5"></i> ${prop.phone}
                            </div>
                            <div class="flex items-center gap-2 text-sm text-gray-700">
                                <i class="fas fa-envelope text-gray-400 w-5"></i> ${prop.email || 'N/A'}
                            </div>
                            <div class="flex gap-2 mt-2">
                                ${prop.flood ? '<span class="text-[10px] bg-red-100 text-red-700 px-2 py-0.5 rounded border border-red-200">Flood Zone</span>' : ''}
                                ${prop.wetland ? '<span class="text-[10px] bg-blue-100 text-blue-700 px-2 py-0.5 rounded border border-blue-200">Wetland</span>' : ''}
                            </div>
                        </div>

                        <div class="flex gap-2 mt-auto pt-3 border-t">
                            <button onclick="openMessageModal('${prop.phone}')" class="flex-1 bg-blue-50 text-blue-700 hover:bg-blue-100 py-2 rounded text-sm font-medium transition">
                                <i class="fas fa-comment-alt"></i> Text
                            </button>
                            <button onclick="editProperty(${prop.id})" class="flex-1 bg-gray-50 text-gray-700 hover:bg-gray-100 py-2 rounded text-sm font-medium transition">
                                <i class="fas fa-edit"></i> Editar
                            </button>
                            <button onclick="deleteProperty(${prop.id})" class="px-3 bg-red-50 text-red-600 hover:bg-red-100 rounded transition">
                                <i class="fas fa-trash"></i>
                            </button>
                        </div>
                    </div>
                `;
                grid.appendChild(card);
            });
        }

        function getStatusColor(status) {
            if (status.includes('Lead') || status.includes('Activo')) return 'bg-blue-600';
            if (status.includes('Llamar')) return 'bg-orange-500';
            if (status.includes('Contrato') || status.includes('Listing')) return 'bg-purple-600';
            if (status.includes('Vendida') || status.includes('Finalizado')) return 'bg-green-600';
            return 'bg-gray-500';
        }

        function filterProperties(status) {
            currentFilter = status;
            // Update buttons visual state
            document.querySelectorAll('.filter-btn').forEach(btn => {
                if(btn.innerText.includes(status) || (status === 'all' && btn.innerText === 'Todos')) {
                    btn.classList.remove('bg-white', 'text-gray-600');
                    btn.classList.add('bg-blue-900', 'text-white');
                } else {
                    btn.classList.add('bg-white', 'text-gray-600');
                    btn.classList.remove('bg-blue-900', 'text-white');
                }
            });
            renderProperties();
        }

        // --- MODAL LOGIC ---
        function openPropertyModal() {
            document.getElementById('propertyForm').reset();
            document.getElementById('propId').value = '';
            document.getElementById('modalTitle').innerText = 'Nueva Propiedad';
            document.getElementById('propertyModal').classList.remove('hidden');
        }

        function closePropertyModal() {
            document.getElementById('propertyModal').classList.add('hidden');
        }

        function editProperty(id) {
            const prop = properties.find(p => p.id === id);
            if (!prop) return;

            document.getElementById('propId').value = prop.id;
            document.getElementById('propUrl').value = prop.url || '';
            document.getElementById('propOwner').value = prop.owner;
            document.getElementById('propPhone').value = prop.phone;
            document.getElementById('propEmail').value = prop.email || '';
            document.getElementById('propBeds').value = prop.beds || '';
            document.getElementById('propBaths').value = prop.baths || '';
            document.getElementById('propSqft').value = prop.sqft || '';
            document.getElementById('propCommission').value = prop.commission || '';
            document.getElementById('propFlood').checked = prop.flood || false;
            document.getElementById('propWetland').checked = prop.wetland || false;
            document.getElementById('propStatus').value = prop.status;
            document.getElementById('propImage').value = prop.image || '';

            document.getElementById('modalTitle').innerText = 'Editar Propiedad';
            document.getElementById('propertyModal').classList.remove('hidden');
        }

        document.getElementById('propertyForm').addEventListener('submit', function(e) {
            e.preventDefault();
            const id = document.getElementById('propId').value;
            
            const newProp = {
                id: id ? parseInt(id) : Date.now(),
                url: document.getElementById('propUrl').value,
                owner: document.getElementById('propOwner').value,
                phone: document.getElementById('propPhone').value,
                email: document.getElementById('propEmail').value,
                beds: document.getElementById('propBeds').value,
                baths: document.getElementById('propBaths').value,
                sqft: document.getElementById('propSqft').value,
                commission: document.getElementById('propCommission').value,
                flood: document.getElementById('propFlood').checked,
                wetland: document.getElementById('propWetland').checked,
                status: document.getElementById('propStatus').value,
                image: document.getElementById('propImage').value
            };

            if (id) {
                const index = properties.findIndex(p => p.id == id);
                properties[index] = newProp;
                showToast('Propiedad actualizada');
            } else {
                properties.push(newProp);
                showToast('Propiedad agregada');
            }

            localStorage.setItem('mamba_properties', JSON.stringify(properties));
            closePropertyModal();
            renderProperties();
        });

        function deleteProperty(id) {
            if(confirm('¿Estás seguro de eliminar esta propiedad?')) {
                properties = properties.filter(p => p.id !== id);
                localStorage.setItem('mamba_properties', JSON.stringify(properties));
                renderProperties();
                showToast('Propiedad eliminada');
            }
        }

        // --- MESSAGING LOGIC ---
        function openMessageModal(phone) {
            document.getElementById('msgTo').value = phone;
            document.getElementById('msgBody').value = '';
            document.getElementById('messageModal').classList.remove('hidden');
        }

        function closeMessageModal() {
            document.getElementById('messageModal').classList.add('hidden');
        }

        function copyTemplate(type) {
            let text = "";
            const signature = "\n\n- Luis Acosta\nMamba Realty LLC\n(239)286-4485";

            switch(type) {
                case 'Greetings': text = "Hello! This is Luis Acosta from Mamba Realty LLC. Just checking in regarding your property interest." + signature; break;
                case 'Contract Info': text = "Hi, sending over the contract details for your review. Please let me know if you have questions." + signature; break;
                case 'Congratulations': text = "Congratulations on the successful sale! It was a pleasure working with you." + signature; break;
                case 'Saludos': text = "¡Hola! Soy Luis Acosta de Mamba Realty LLC. Le escribo para dar seguimiento a su interés en la propiedad." + signature; break;
                case 'Info Contrato': text = "Hola, le envío los detalles del contrato para su revisión. Quedo atento." + signature; break;
                case 'Felicitaciones': text = "¡Felicitaciones por haber cerrado el trato y obtener una venta exitosa! Fue un placer trabajar con usted." + signature; break;
            }

            // If modal is open, fill it. If not, just copy to clipboard and notify
            const modal = document.getElementById('messageModal');
            if (!modal.classList.contains('hidden')) {
                document.getElementById('msgBody').value = text;
            } else {
                navigator.clipboard.writeText(text);
                showToast('Plantilla copiada al portapapeles');
            }
        }

        function sendMessage() {
            const to = document.getElementById('msgTo').value;
            const body = document.getElementById('msgBody').value;
            
            // Simulation of sending
            console.log(`Sending SMS from (239)286-4485 to ${to}: ${body}`);
            
            closeMessageModal();
            showToast('Mensaje enviado exitosamente');
        }

        // --- CALENDAR LOGIC ---
        function renderCalendar() {
            const grid = document.getElementById('calendarDays');
            grid.innerHTML = '';
            
            const year = currentDate.getFullYear();
            const month = currentDate.getMonth();
            
            const monthNames = ["Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre"];
            document.getElementById('currentMonthYear').innerText = `${monthNames[month]} ${year}`;

            const firstDay = new Date(year, month, 1).getDay();
            const daysInMonth = new Date(year, month + 1, 0).getDate();

            // Empty cells for previous month
            for (let i = 0; i < firstDay; i++) {
                const cell = document.createElement('div');
                cell.className = 'bg-gray-50 border border-gray-100';
                grid.appendChild(cell);
            }

            // Days
            for (let i = 1; i <= daysInMonth; i++) {
                const cell = document.createElement('div');
                cell.className = 'calendar-day hover:bg-blue-50 cursor-pointer transition relative group';
                cell.innerHTML = `<span class="font-bold text-gray-700">${i}</span>`;
                
                // Add dummy appointment for demo
                if (i === 15 || i === 22) {
                    cell.innerHTML += `<div class="mt-2 text-xs bg-blue-100 text-blue-800 p-1 rounded border-l-2 border-blue-500">Cita Propiedad</div>`;
                }

                cell.onclick = () => alert(`Agregar cita para el día ${i} de ${monthNames[month]}`);
                grid.appendChild(cell);
            }
        }

        function changeMonth(delta) {
            currentDate.setMonth(currentDate.getMonth() + delta);
            renderCalendar();
        }

        // --- UTILS ---
        function showToast(message) {
            const toast = document.getElementById('toast');
            document.getElementById('toastMsg').innerText = message;
            toast.classList.remove('translate-y-20', 'opacity-0');
            setTimeout(() => {
                toast.classList.add('translate-y-20', 'opacity-0');
            }, 3000);
        }

    </script>
</body>
</html>
```
