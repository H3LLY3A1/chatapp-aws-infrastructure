#Do przeslania klucza
scp -i MyKey.pem MyKey.pem ec2-user@3.88.14.95:/home/ec2-user/

# potem na froncie
chmod 600 ~/MyKey.pem
ssh -i ~/MyKey.pem ec2-user@10.0.2.5

# potem na back
sudo yum update -y
sudo amazon-linux-extras install docker -y
sudo systemctl start docker
sudo systemctl enable docker
sudo usermod -aG docker ec2-user

exit


docker build -f Dockerfile.frontend -t nashsg1/frontend:latest .
