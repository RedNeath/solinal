# Building Lua
curl -L -R -O https://www.lua.org/ftp/lua-5.4.7.tar.gz
tar zxf lua-5.4.7.tar.gz
rm lua-5.4.7.tar.gz
cd lua-5.4.7
make # this will build lua locally

# Clean Lua install
cd ..
mkdir bin
mkdir include
mv lua-5.4.7/src/lua bin/lua
mv lua-5.4.7/src/*.h include/
rm -Rf lua-5.4.7/

# Building luarocks
curl -L -R -O https://luarocks.github.io/luarocks/releases/luarocks-3.11.1.tar.gz
tar zxf luarocks-3.11.1.tar.gz
rm luarocks-3.11.1.tar.gz
cd luarocks-3.11.1
./configure --prefix=.. --with-lua=.. 
make
make install

# Clean luarocks install
cd ..
rm -Rf luarocks-3.11.1/

# Install lua modules
./bin/luarocks install lunajson
./bin/luarocks install split
